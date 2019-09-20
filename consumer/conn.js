const amqp = require('amqplib');
const chalk = require('chalk');
const program = require('commander');

function sleep(seconds) {
  return new Promise((resolve) => {
    setTimeout(resolve, seconds * 1000);
  });
}

program
  .arguments('<port> <delay>')
  .option('-q, --quiet', 'No output')
  .action(async (port, delay, options) => {
    const conn = await amqp.connect(`amqp://localhost:${port}/`);
    if (!options.quiet) console.log(chalk.bold.green('CONNECTED'));
    if (!options.quiet) console.log(`sleep ${delay}`);
    await sleep(delay);
    if (!options.quiet) console.log('closing');
    await conn.close();
    if (!options.quiet) console.log(chalk.bold.green('CLOSED'));
  })
  .parse(process.argv);
