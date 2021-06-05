module MongoDb.Query
  ( Condition(..)
  , class IsQuery
  , by
  , class IsQueryRecord
  , writeQueryRecord
  , Query
  , class UnNest
  , class UnNestFields
  , empty
  , and
  , or
  , not
  , eq
  , ne
  , in'
  , nin
  , lt
  , lte
  , gt
  , gte
  , text
  , elemMatch
  ) where

import Prelude

import MongoDb.Types (TextQuery)
import Foreign (Foreign)
import Record as Record
import Record.Builder (Builder)
import Record.Builder as Builder
import Simple.JSON (class WriteForeign, write)
import Type.Prelude (class IsSymbol, RLProxy(..), SProxy(..))
import Prim.RowList (class RowToList, Cons, Nil)
import Prim.Row as Row
import Unsafe.Coerce (unsafeCoerce)


foreign import data Query :: Type -> Type
foreign import data Condition :: Type -> Type


empty :: ∀ a. Query a
empty = unsafeCoerce {}


and :: ∀ a. Array (Query a) -> Query a
and qs = unsafeCoerce $ write { "$and": write qs }


or :: ∀ a. Array (Query a) -> Query a
or qs = unsafeCoerce $ write { "$or": write qs }


not :: ∀ a. Query a -> Query a
not q = unsafeCoerce $ write { "$not": write q }


eq :: ∀ a. WriteForeign a => a -> Condition a
eq v = unsafeCoerce $ write { "$eq": v }


ne :: ∀ a. WriteForeign a => a -> Condition a
ne v = unsafeCoerce $ write { "$ne": v }


in' :: ∀ a. WriteForeign a => Array a -> Condition a
in' vs = unsafeCoerce $ write { "$in": write vs }


nin :: ∀ a. WriteForeign a => Array a -> Condition a
nin vs = unsafeCoerce $ write { "$nin": write vs }


lt :: ∀ a. WriteForeign a => a -> Condition a
lt v = unsafeCoerce $ write { "$lt": v }


lte :: ∀ a. WriteForeign a => a -> Condition a
lte v = unsafeCoerce $ write { "$lte": v }


gt :: ∀ a. WriteForeign a => a -> Condition a
gt v = unsafeCoerce $ write { "$gt": v }


gte :: ∀ a. WriteForeign a => a -> Condition a
gte v = unsafeCoerce $ write { "$gte": v }


text :: TextQuery -> Condition String
text query = unsafeCoerce $ write { "$text": query }


elemMatch :: ∀ a. Query a -> Condition (Array a)
elemMatch q = unsafeCoerce $ write { "$elemMatch": q }


instance writeForeignCondition :: WriteForeign (Condition a) where
  writeImpl = unsafeCoerce


instance writeForeignQuery :: WriteForeign (Query a) where
  writeImpl = unsafeCoerce


class IsQuery a from | a -> from where
  by :: a -> Query from


instance recordWriteQuery ::
  ( RowToList row rl
  , IsQueryRecord rl row orig () to
  ) => IsQuery (Record row) (Record orig) where
  by rec = unsafeCoerce $ Builder.build steps {}
    where
      rlp = RLProxy :: RLProxy rl
      steps = writeQueryRecord rlp rec


class IsQueryRecord :: forall k. k -> Row Type -> Row Type -> Row Type -> Row Type -> Constraint
class IsQueryRecord rl row (orig :: # Type) (from :: # Type) (to :: # Type)
  | rl -> row from to orig where
  writeQueryRecord :: forall g. g rl -> Record row -> Builder (Record from) (Record to)


instance consWriteQueryFields ::
  ( IsSymbol name
  , IsQueryRecord tail row orig from from'
  , UnNest ty ty'
  , WriteForeign ty
  , Row.Cons name ty whatever row
  , Row.Cons name ty' orig' orig
  , Row.Lacks name from'
  , Row.Cons name Foreign from' to
  ) => IsQueryRecord (Cons name ty tail) row orig from to where
  writeQueryRecord _ rec = result
    where
      namep = SProxy :: SProxy name
      value = Record.get namep rec
      tailp = RLProxy :: RLProxy tail
      rest = writeQueryRecord tailp rec
      result = Builder.insert namep (write value) <<< rest


instance nilWriteQueryFields ::
  IsQueryRecord Nil row orig () () where
  writeQueryRecord _ _ = identity


class UnNest :: ∀ k1 k2. k1 -> k2 -> Constraint
class UnNest a b


instance unnestCondition :: UnNest (Condition a) a


instance unnestArrayCondition :: UnNest (Array (Condition a)) (Array a)


instance recordUnNest ::
  ( RowToList row rl
  , UnNestFields rl out
  ) => UnNest (Record row) out


instance recordArrayUnNest ::
  ( RowToList row rl
  , UnNestFields rl out
  ) => UnNest (Array (Record row)) (Array out)


class UnNestFields :: forall k1 k2. k1 -> k2 -> Constraint
class UnNestFields rl row | rl -> row


instance consUnNestFields ::
  ( Row.Cons name ty' whatever row
  , UnNest ty ty'
  ) => UnNestFields (Cons name ty tail) (Record row)


instance nilUnNestFields :: UnNestFields Nil row
