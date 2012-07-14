fs = require('fs');


class LoadEnv
  
  @load: ->
    data = fs.readFileSync('./.env', 'ascii');
    
    lines = data.split("\n")
    for line in lines
      if line.length > 0
        pairs = line.split "="
        process.env[pairs[0]] = pairs[1]

module.exports = LoadEnv
