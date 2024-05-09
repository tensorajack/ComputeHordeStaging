For setting up SN12 on staging

The install docker bash script will work for both miners and validators. 

1. You run the miner exactly as with prod
2. With the validator, first head to the envs/runner directory and rebuild the image commenting out facilitator connector

Validator

Once you have the validator and miner connected and running: 
1. Ensure you have staked at least 10 TAO to the validator, it may need to be more I aim for 1000. 
2. Exec into the validator-app-1 container, as in here you can run commands to send synthetic jobs. 
        
        Commands: python manage.py help (This will show you the commands available)
