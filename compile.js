// open and read the file
const fs = require('fs');

var file = fs.readFileSync('example.dpl', 'utf8');

// remove everything inside ``
file = file.replace(/`[^`]*`/g, '');

// get all packages loadings and remove them
var packages = file.match(/^(from +'(?<directory>[^']+)' +)?load +'(?<package>[^']+)'( +as +(?<name>[a-zA-Z]+))?$/g);
file = file.replace(/^(from +'(?<directory>[^']+)' +)?load +'(?<package>[^']+)'( +as +(?<name>[a-zA-Z]+))?$/g, '');

console.log(packages);
