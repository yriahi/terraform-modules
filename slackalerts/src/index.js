const {SNSSlackPublisher} = require('@lastcall/sns-slack-alerts-consumer');
const {SLACK_TOKEN, DEFAULT_CHANNEL, TOPIC_MAP} = process.env;

// Slack message settings for topics that don't have a special setting:
const defaultMessage = {
    as_user: true,
    channel: DEFAULT_CHANNEL
}

// Map of special topics to slack message bodies:
const topicMap = JSON.parse(TOPIC_MAP).map(item => {
    return {
        [item.topic_arn]:  {
            username: item.username,
            icon_emoji: item.icon_emoji,
            as_user: false,
            channel: item.channel
        }
    }
})

console.log(topicMap);

const publisher = new SNSSlackPublisher(SLACK_TOKEN, defaultMessage, topicMap);

exports.handler = async function(data, context, callback) {
    const messages = data.Records.map(record => {
        return publisher.publish(record);
    })
    return Promise.all(messages)
}


