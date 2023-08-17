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
  --, text
  , elemMatch
  ) where


import Prelude

import Data.Argonaut.Core (Json)
import Data.Argonaut.Encode (class EncodeJson, encodeJson)
import Prim.Row as Row
import Prim.RowList (class RowToList, Cons, Nil)
import Record as Record
import Record.Builder (Builder)
import Record.Builder as Builder
import Type.Prelude (class IsSymbol)
import Type.Proxy (Proxy(..))
import Unsafe.Coerce (unsafeCoerce)


foreign import data Query :: Type -> Type
foreign import data Condition :: Type -> Type


write :: ∀ a. EncodeJson a => a -> Json
write = encodeJson


empty :: ∀ a. Query a
empty = unsafeCoerce {}


and :: ∀ a. Array (Query a) -> Query a
and qs = unsafeCoerce $ write { "$and": write qs }


or :: ∀ a. Array (Query a) -> Query a
or qs = unsafeCoerce $ write { "$or": write qs }


not :: ∀ a. Query a -> Query a
not q = unsafeCoerce $ write { "$not": write q }


eq :: ∀ a. EncodeJson a => a -> Condition a
eq v = unsafeCoerce $ write { "$eq": v }


ne :: ∀ a. EncodeJson a => a -> Condition a
ne v = unsafeCoerce $ write { "$ne": v }


in' :: ∀ a. EncodeJson a => Array a -> Condition a
in' vs = unsafeCoerce $ write { "$in": write vs }


nin :: ∀ a. EncodeJson a => Array a -> Condition a
nin vs = unsafeCoerce $ write { "$nin": write vs }


lt :: ∀ a. EncodeJson a => a -> Condition a
lt v = unsafeCoerce $ write { "$lt": v }


lte :: ∀ a. EncodeJson a => a -> Condition a
lte v = unsafeCoerce $ write { "$lte": v }


gt :: ∀ a. EncodeJson a => a -> Condition a
gt v = unsafeCoerce $ write { "$gt": v }


gte :: ∀ a. EncodeJson a => a -> Condition a
gte v = unsafeCoerce $ write { "$gte": v }


-- text :: TextQuery -> Condition String
-- text query = unsafeCoerce $ write { "$text": query }


elemMatch :: ∀ a. Query a -> Condition (Array a)
elemMatch q = unsafeCoerce $ write { "$elemMatch": q }


instance EncodeJson (Condition a) where
  encodeJson = unsafeCoerce


instance EncodeJson (Query a) where
  encodeJson = unsafeCoerce


class IsQuery a from | a -> from where
  by :: a -> Query from


instance recordWriteQuery ::
  ( RowToList row rl
  , IsQueryRecord rl row orig () to
  ) => IsQuery (Record row) (Record orig) where
  by rec = unsafeCoerce $ Builder.build steps {}
    where
      rlp = Proxy :: Proxy rl
      steps = writeQueryRecord rlp rec


class IsQueryRecord :: forall k. k -> Row Type -> Row Type -> Row Type -> Row Type -> Constraint
class IsQueryRecord rl row (orig :: Row Type) (from :: Row Type) (to :: Row Type)
  | rl -> row from to orig where
  writeQueryRecord :: forall g. g rl -> Record row -> Builder (Record from) (Record to)


instance consWriteQueryFields ::
  ( IsSymbol name
  , IsQueryRecord tail row orig from from'
  , UnNest ty ty'
  , EncodeJson ty
  , Row.Cons name ty whatever row
  , Row.Cons name ty' orig' orig
  , Row.Lacks name from'
  , Row.Cons name Json from' to
  ) => IsQueryRecord (Cons name ty tail) row orig from to where
  writeQueryRecord _ rec = result
    where
      namep = Proxy :: Proxy name
      value = Record.get namep rec
      tailp = Proxy :: Proxy tail
      rest = writeQueryRecord tailp rec
      result = Builder.insert namep (write value) <<< rest


instance IsQueryRecord Nil row orig () () where
  writeQueryRecord _ _ = identity


class UnNest :: ∀ k1 k2. k1 -> k2 -> Constraint
class UnNest a b


instance UnNest (Condition a) a


instance UnNest (Array (Condition a)) (Array a)


instance
  ( RowToList row rl
  , UnNestFields rl out
  ) => UnNest (Record row) out
instance
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
