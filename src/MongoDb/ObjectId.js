import { ObjectId } from "bson";

export const equals = (id) => {
  return (id2) => {
    return id.equals(id2);
  };
};

export const toHexString = (id) => {
  return id.toHexString();
};

export const generate = () => {
  return new ObjectId();
};

export const fromString = function (s) {
  return new ObjectId(s);
};
