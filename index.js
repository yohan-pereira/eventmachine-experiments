const http = require('http')
const port = 3000

function randomIntFromInterval(min,max)
{
    return Math.floor(Math.random()*(max-min+1)+min);
}

const requestHandler = (request, response) => {
  let timeout = randomIntFromInterval(6000,8000)
  console.log(request.url + " responding in " + timeout)
  setTimeout(() => response.end('Hello Node.js Server!'), timeout)
}

const server = http.createServer(requestHandler)

server.listen(port, (err) => {
  if (err) {
    return console.log('something bad happened', err)
  }

  console.log(`server is listening on ${port}`)
})
