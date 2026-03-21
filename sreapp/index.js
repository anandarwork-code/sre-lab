const mysql = require('mysql2');

const connection = mysql.createConnection({
	host: '192.168.122.127',
	user: 'sreapp' ,
	password: 'Oneseven@2003',
	database:'srelab'
});

connection.connect((err) => {
	if (err) {
		console.error('DB connectio failed:', err.message);
		process.exit(1);
	}
	console.log('Connected to MySQL on sre-lab sucessfully');
	connection.end();
});
