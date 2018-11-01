// A super dumb native array extension to add db-like functionality

Array.prototype.deleteBy = function(field, value) {
  for (var index = 0; index < this.length; index++) {
    var element = this[index];
    if (element[field] == value) this.splice(index, 1)
  }
}

Array.prototype.replaceBy = function(field, value, newData) {
  for (var index = 0; index < this.length; index++) {
    var element = this[index];
    if (element[field] == value) this.splice(index, 1, newData);
  }
}

Array.prototype.upsertBy = function(field, value, newData) {
  for (var index = 0; index < this.length; index++) {
    var element = this[index];
    if (element[field] == value) {
      this.splice(index, 1, newData);
      return
    }
  }
  this.push(newData);
}

Array.prototype.update = function(record) {
  if (record.deleted) {
    this.delete(record)
  }
  else {
    this.upsert(record)
  }
}

Array.prototype.delete = function(record) {
  this.deleteBy('id', record.id)
}

Array.prototype.upsert = function(record) {
  this.upsertBy('id', record.id, record)
}

Array.prototype.orderBy = function(field, dir) {
  if (typeof(dir) == 'undefined') dir = 'asc'
  var multi = {asc: 1, desc: -1}
  return this.slice(0).sort(function(a, b) {
    return a[field] < b[field] ? multi[dir] * -1 : multi[dir]
  })
}