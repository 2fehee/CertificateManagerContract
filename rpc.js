const xhr = process.browser ? require('xhr') : require('request')
const inherits = require('util').inherits
const createPayload = require('../util/create-payload.js')
const Subprovider = require('./subprovider.js')
const { ethErrors, serializeError } = require('eth-json-rpc-errors')


module.exports = RpcSource

inherits(RpcSource, Subprovider)

function RpcSource(opts) {
  const self = this
  self.rpcUrl = opts.rpcUrl
}

RpcSource.prototype.handleRequest = function(payload, next, end){
  const self = this
  const targetUrl = self.rpcUrl

  // overwrite id to conflict with other concurrent users
  const sanitizedPayload = sanitizePayload(payload)
  const newPayload = createPayload(sanitizedPayload)

  let jwt_token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJwZXJtaXNzaW9ucyI6WyJuZXQ6KiIsImV0aDoqIiwiZGVidWc6KiIsInR4cG9vbDoqIiwiZWVhOioiXSwiZXhwIjoxNjA3MTQ3MzAzLCJ0ZWFtIjoiMDIifQ.T-HvZuPKz9ak67IJKmh6cD3_VatmxogS1hgUG3BEtL3D6MpOoR-D1WmBbYbXlzNlI3VdLvmwDvXhYogneN5TwTJEC_dI9UHc-LR8wW4KXsY-hLLacDXaOaFh60bYmWjA3XDXXa5ulcp08cuSG-iX-77Fm--XAIcYHPtyEg93ZzDUFbLnxYWO3vJWr8H9_TnGBGsfBG8O-6SGqxSxDv8dReRpSTsYQuJKM1yt8YeTwWLeWHffomMq-rZ72dyG6V9FY6bCJDvl9OsWdVTFe61Ch59ZLf4HLSOEmoDM6I2-A4p0viN14-A0S6BB3iFaq66yvkXZk72qspC0svWjoJMPvg";

  xhr({
    uri: targetUrl,
    method: 'POST',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      "Authorization": "Bearer " + jwt_token
    },
    body: JSON.stringify(newPayload),
    rejectUnauthorized: false,
    timeout: 20000,
  }, function(err, res, body) {
    if (err) return end(serializeError(err))

    // check for error code
    switch (res.statusCode) {
      case 405:
        return end(ethErrors.rpc.methodNotFound())
      case 504: // Gateway timeout
        return (function(){
          let msg = `Gateway timeout. The request took too long to process. `
          msg += `This can happen when querying logs over too wide a block range.`
          const err = new Error(msg)
          return end(serializeError(err))
        })()
      case 429: // Too many requests (rate limiting)
        return (function(){
          const err = new Error(`Too Many Requests`)
          return end(serializeError(err))
        })()
      default:
        if (res.statusCode != 200) {
          const msg = 'Unknown Error: ' + res.body
          const err = new Error(msg)
          return end(serializeError(err))
        }
    }

    // parse response
    let data
    try {
      data = JSON.parse(body)
    } catch (err) {
      console.error(err.stack)
      return end(serializeError(err))
    }
    if (data.error) return end(data.error)

    end(null, data.result)
  })
}

// drops any non-standard params
function sanitizePayload (payload) {
  return {
    id: payload.id,
    jsonrpc: payload.jsonrpc,
    method: payload.method,
    params: payload.params,
  }
}
