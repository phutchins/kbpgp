{SHA512,alloc} = require './hash'
K = require('./const').keybase

#==============

sign = ({key, type, body, hash, progress_hook}, cb) ->
  # XXX change to RSA-PSS.  See Issue #4
  hash = SHA512 unless hash?
  header = 
    type : type
    version : K.versions.V1
    hash : hash.type
    padding : K.padding.EMSA_PCKS1_v1_5

  payload = pack { body, header }
  sig = key.pad_and_sign payload, { hash : hash }
  output = { header, sig }
  cb null, output

#==============

verify = ({key, sig, body, progress_hook}, cb) ->
  hd = sig.header
  payload = pack { header : hd, body}
  hash = alloc header.hash
  err = if hd.version isnt K.versions.V1 then new Error "unknown version: #{header.version}"
  else if hd.padding isnt K.padding.EMSA_PCKS1_v1_5 then new Error "unknown padding: #{header.padding}"
  else key.verify_unpad_and_check_hash sig.sig, payload, hash
  cb err

#==============

exports.sign = sign
exports.verify = verify

#==============



