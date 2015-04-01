(function() {

    var logger = console;

    this.init = function(customLogger)
    {
        logger = customLogger;
    }

    this.run = function(params, done)
    {
        logger.info("======================================================================");
        logger.info("Running job " + __dirname);
        logger.info("======================================================================");
        logger.debug(params);

        var exec = require('child_process').exec;
        var commands = [
            "rvm use 1.9.3",
            "bundle install",
            "rm -Rf data/blog",
            "rm -Rf data/resources",
            "bundle exec middleman contentful",
            "bundle exec middleman resources",
            "bundle exec middleman build"
        ];
        
        var environment = process.env;

        // Deploy to github pages if this is the production branch, otherwise
        // just compile it locally
        if (params.branch == "production")
        {
            commands.push("middleman deploy");
            
            environment.KO_QA = "false";
        }
        else
        {
            commands.push("rm -Rf " + __dirname + "/live");
            commands.push("mv " + __dirname + "/build " + __dirname + "/live");
            
            environment.KO_QA = "true";
        }

        environment.PATH = environment.PATH + ":/usr/local/bin:/usr/bin:/home/nathanr/.rvm/gems/ruby-1.9.3-p551/bin:/home/nathanr/.rvm/gems/ruby-1.9.3-p551@global/bin:/home/nathanr/.rvm/rubies/ruby-1.9.3-p551/bin:/home/nathanr/.rvm/bin:/home/nathanr/.nvm/v0.10.25/bin";
        environment.GEM_HOME = "/home/nathanr/.rvm/gems/ruby-1.9.3-p551";
        environment.GEM_PATH = "/home/nathanr/.rvm/gems/ruby-1.9.3-p551:/home/nathanr/.rvm/gems/ruby-1.9.3-p551@global";

        var envVars = require(__dirname + "/../komodo-website-" + params.branch + ".env.js");
        for (var env in envVars)
        {
            environment[env] = envVars[env];
        }

        var runCommand = function(index)
        {
            if ( ! (index in commands)) return done();

            var command = commands[index];
            logger.info("Executing " + command);
            exec(command, {
                maxBuffer: 1000*1024,
                env: environment,
                cwd: __dirname
            },
            function(err, stdo, stde)
            {
                if (err) return done(err);
                logger.debug("Result: " + stdo + stde + "\n");
                runCommand(++index);
            });
        }

        runCommand(0);
    };
    
    this.schedule = function(branch, cron, deploy)
    {
        logger.info("Scheduling deployment for " + __dirname + " : " + branch);

        var doDeploy = function()
        {
            deploy({
                name: 'komodo-website-' + branch,
                path: __dirname,
                repository: 'komodo-website',
                branch: branch
            });
        };

        // Deploy latest version every 3 hours
        new cron('0 */3 * * *', function(){
            logger.info('Running scheduled deploy for ' + __dirname);
            doDeploy();
        }, null, true);

        doDeploy();
    };

}).apply(module.exports);