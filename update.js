// debug
process.on('uncaughtException', function (error) {
    console.log(error.stack);
});

var schedule = require('node-schedule');
var exec = require('child_process').exec;

var cronTime = '19,39,59 * * * *'; // every 20 minutes, starting on 19
var command = __dirname + '/update.sh';
console.log('cronTime: ' + cronTime + '\ncommand: ' + command);

schedule.scheduleJob(cronTime, function () {
	var timestamp = new Date().toISOString();
	console.log('\n' + timestamp);
	
	exec(command, function (error, stdout, stderr) {
		if(stdout) {
			console.log(stdout.trim());
		}
		if(stderr) {
			console.log(stderr.trim());
		}
		if (error !== null) {
			console.log(error);
		}
	});
});