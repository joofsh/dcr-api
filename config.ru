require './app'

NewRelic::Agent.manual_start

run EhrAPI.app

