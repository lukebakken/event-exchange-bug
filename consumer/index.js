const amqp = require('amqplib');
const chalk = require('chalk');

const eventExchange = 'amq.rabbitmq.event';

function handleMsg(msg) {
  const [resource, action] = msg.fields.routingKey.split('.');
  if (resource !== 'connection') return;
  console.log(action);
}

async function main() {
  const conn = await amqp.connect('amqp://localhost/');
  console.log(chalk.bold.green('CONNECTED'));
  const channel = await conn.createConfirmChannel();
  const tempQueue = await channel.assertQueue('', { exclusive: true, autoDelete: true });

  await channel.bindQueue(tempQueue.queue, eventExchange, '#', {});
  channel.consume(tempQueue.queue, handleMsg, { noAck: true });
  console.log(chalk.bold.green('READY'));
}

try {
  main();
} catch(err) {
  console.dir(err);
}
