// Load and execute an external JS resource whose URL depends on a configuration 
// variable specific to a domain/account

CloudFlare.define(
    'sociocast',
    ['sociocast/config'],
    function(config) {

        // config will be an object containing any configurations that will be
        // stored by CloudFlare, specific to app + domain combo

        // build the URL for your JS resource
        var url = 'http://ajs.sociocast.com/'+config.client_id+'/sociocast.js';

        // load and execute file
        CloudFlare.require([url]);
    }
);