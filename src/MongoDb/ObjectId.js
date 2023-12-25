import { ObjectId } from "mongodb"

export const equals = id => {
  return id2 => {
    return id.equals(id2)
  }
}

export const toHexString = id => {
  return id.toHexString()
}

export const generate = () => {
  return new ObjectId()
}

export const fromString_ = left => right => s => {
  try {
    return right(new ObjectId(s))
  } catch (e) {
    return left(e)
  }
}
