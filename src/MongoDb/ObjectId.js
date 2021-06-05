"use strict";

/**
 * @param {import("bson").ObjectId} id
 */
exports.equals = (id) => {
  return (id2) => {
    return id.equals(id2);
  };
};

/**
 * @param {import("bson").ObjectId} id
 */
exports.toHexString = (id) => {
  return id.toHexString();
};

exports.generate = () => {
  const { ObjectId } = require("bson");

  return new ObjectId();
};

exports.fromString = function (s) {
  const { ObjectId } = require("bson");
  return new ObjectId(s);
};
