import { ObjectId } from "mongodb"

/**
 *
 * @param {ObjectId} id
 * @returns {(p: ObjectId) => boolean}
 */
export const equals = id => {
  return id2 => {
    return id.equals(id2)
  }
}
/**
 *
 * @param {ObjectId} id
 * @returns {string}
 */
export const toHexString = id => {
  return id.toHexString()
}

export const generate = () => {
  return new ObjectId()
}

//@ts
export const fromString_ = left => right => s => {
  try {
    return right(ObjectId.createFromHexString(s))
  } catch (e) {
    return left(e)
  }
}
