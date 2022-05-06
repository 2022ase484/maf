package maf.aam.scheme.stores

import maf.aam.scheme.BaseSchemeAAMSemantics
import maf.aam.{AAMGraph, BaseSimpleWorklistSystem, GraphElementAAM}
import maf.language.scheme.SchemeExp
import maf.core.{Address, BasicStore, Lattice}

object DepLoggingStore:
    def from[V: Lattice](sto: BasicStore[Address, V], tt: Int): DepLoggingStore[V] =
      DepLoggingStore(sto, Map().withDefaultValue(List()), Set(), tt)

/** A logging store that keeps track of the read dependencies in addition to the changes that it makes. */
case class DepLoggingStore[V: Lattice](originalSto: BasicStore[Address, V], W: Map[Address, List[V]], R: Set[Address], tt: Int):
    /** Replays the store against the given global store. Returns the set of addresses that it has affected */
    def replay(store: BasicStore[Address, V]): (BasicStore[Address, V], Set[Address]) =
        val (sto1, writes) = W.foldLeft((store, Set[Address]())) { case ((store, writes), (adr, vlus)) =>
          val before = store.lookup(adr)
          val newStore = vlus.foldLeft(store)((sto, vlu) => sto.extend(adr, vlu))
          (newStore, if before != newStore.lookup(adr) then writes + adr else writes)
        }

        (sto1, writes)

    /** Append the given write to the log */
    def append(a: Address, value: V): DepLoggingStore[V] =
      this.copy(W = W + (a -> (value :: W(a))))

    /** Returns true if the address is already part of the log */
    def contains(a: Address): Boolean = W.contains(a)

    /** Returns the value from the log */
    def lookup(addr: Address): V =
      W.get(addr)
        .getOrElse(List())
        .foldLeft(Lattice[V].bottom)((joined, vlu) => Lattice[V].join(joined, vlu))

    /** Register a read dependency from the current state to the given address */
    def register(readDep: Address): DepLoggingStore[V] =
      this.copy(R = R + readDep)

    def readDeps: Set[Address] = R

/** A logging store were we also keep track of the dependencies, so that components are not re-analyzed unnecessarily */
trait BaseSchemeDependencyLoggingStore extends BaseSchemeAAMSemantics, BaseSimpleWorklistSystem[SchemeExp]:
    type Sto = DepLoggingStore[Storable]
    type Conf = SchemeConf
    type System = DepLoggingStoreSystem

    private var originalSto = BasicStore(initialBds.map(p => (p._2, p._3)).toMap).extend(Kont0Addr, Storable.K(Set(HltFrame)))
    private var sto: BasicStore[Address, Storable] = originalSto
    private var logs: List[DepLoggingStore[Storable]] = List()
    private var t: Int = 0

    class DepLoggingStoreSystem extends SeenStateSystem:
        /** A global version of the R set (read dependencies) */
        private var R: Map[Address, Set[Conf]] = Map().withDefaultValue(Set())

        /**
         * A set of possible successor states (generated by the effecs). If we encounter a successor, we simply need to check whether the successor is
         * in this list. If that is the case we can add it to the worklist.
         */
        private var candidates: Set[Conf] = Set()

        /** Replay the logs from all the collected stores in the global store, and return the set of address that were written */
        private def appendAll(logs: List[DepLoggingStore[Storable]]): Set[Address] =
            val (sto1, writes) = logs.foldLeft((sto, Set[Address]())) { case ((sto, writes), log) =>
              val (sto1, writes1) = log.replay(sto)
              (sto1, writes ++ writes1)
            }

            sto = sto1
            writes

        override def popWork(): Option[(Option[Conf], Conf)] =
            if work.isEmpty && newWork.nonEmpty then
                // we exhausted our previous worklist lets get started on the frontier (the successors of the previous worklist)
                val writes = appendAll(logs)

                // we may now forget the logs
                logs = List()

                // Only add those to the worklist that are in the candidate list
                val tmpWorkList = newWork.toSet
                  .filter { case (_, conf) =>
                    writes.exists(a => R(a).contains(conf)) || !seen.contains(conf)
                  }
                  .map { (prev, conf) => (prev, conf.copy(tt = t)) }
                  .toList

                tmpWorkList.foreach(c => addSeen(c._2))

                (newWork.toSet -- tmpWorkList.toSet).foreach {
                  case (Some(from), to) => addBump(from, to)
                  case _                => println(s"warn")
                }

                // if the writes are > 0 then we increment t
                t = if writes.isEmpty then t else t

                work = tmpWorkList
                newWork = List()
            super.popWork()

        def register(conf: Conf, a: Address): Unit =
          R = R + (a -> (R(a) + conf))

    case class SchemeConf(c: Control, k: Address | Frame, t: Timestamp, extra: Ext, tt: Int)

    override def decideSuccessors[G](depGraph: G, prev: Conf, successors: Set[State], sys: System)(using AAMGraph[G]): (System, G) =
        successors.foreach { successor =>
            val conf = asConf(successor, sys)
            sys.pushWork(Some(prev), conf)
            logs = successor.s :: logs
            successor.s.readDeps.foreach(sys.register(prev, _))
        }

        (sys, depGraph)

    override def writeSto(sto: Sto, addr: Address, value: Storable): Sto =
      sto.append(addr, value)

    override def readSto(sto: Sto, addr: Address): (Storable, Sto) =
      if sto.contains(addr) then
          // look in the log for the value, this is different in the Optimizing AAM paper
          // as we assume there that the invriant holds that states do not read from the log
          (sto.lookup(addr), sto.register(addr))
      else
          println(s"lookup for $addr yields ${sto.originalSto.lookup(addr)}")
          (sto.originalSto.lookup(addr).getOrElse(Storable.V(lattice.bottom)), sto.register(addr))

    override def asState(conf: Conf, sys: System): State =
      SchemeState(conf.c, DepLoggingStore.from(sto, conf.tt), conf.k, conf.t, conf.extra)

    override def asConf(state: State, sys: System): Conf =
      SchemeConf(state.c, state.k, state.t, state.extra, state.s.tt)

    override def injectConf(e: Expr): Conf =
      SchemeConf(Control.Ev(e, initialEnv), Kont0Addr, initialTime, emptyExt, 0)

    override def inject(e: Expr): System =
      DepLoggingStoreSystem().pushWork(None, injectConf(e))

    override def asGraphElement(c: Conf, sys: System): GraphElementAAM =
      asGraphElement(c.c, c.k, DepLoggingStore.from(sto, c.tt), c.extra, c.hashCode)

    override lazy val initialStore: Sto = DepLoggingStore.from(originalSto, 0)