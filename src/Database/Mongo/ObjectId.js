'use strict';

exports._show = function (oid) {
  return oid;
}

exports._eq = function (a) {
  return function (b) {
    return a === b;
  }
}

exports.fromString = function (s) {
  return s;
}
