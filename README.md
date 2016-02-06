# Coldbox Couchbase Provider Module
The CacheBox Couchbase Provider is an Coldbox module that allows you to connect CacheBox to a Couchbase cluster and then leverage that cluster in your ColdBox applications or any application that leverages CacheBox in its standalone version.

##LICENSE
Apache License, Version 2.0.

##IMPORTANT LINKS
- Documentation: http://wiki.coldbox.org/wiki/CacheBox-Couchbase.cfm
- Source: https://github.com/ColdBox/cachebox-couchbase
- ForgeBox: http://forgebox.io/view/cachebox-prorvider

##SYSTEM REQUIREMENTS
- Lucee 4.5+
- Railo 4+ (Deprecated)
- ColdFusion 9+

## INSTRUCTIONS

Just drop into your **modules** folder or use the box-cli to install

`box install couchbase-provider`


## Settings
You can add a `Couchbase` structure of settings to your `ColdBox.cfc` to configure custom caches:

```js
//The global Couchbase settings config
Couchbase = {
	// Register all the custom named caches you like here
    caches : { 
		"template" : {
			properties : {
			    objectDefaultTimeout : 15,
			    opQueueMaxBlockTime : 5000,
			    opTimeout : 5000,
			    timeoutExceptionThreshold : 5000,
			    ignoreCouchBaseTimeouts : true,				
				bucket:"default",
				username:"",
				password:"",
				servers:"127.0.0.1:8091"
			}
		},
		"couchBase" : {
		    properties : {
		        objectDefaultTimeout : 15,
		        opQueueMaxBlockTime : 5000,
		        opTimeout : 5000,
		        timeoutExceptionThreshold : 5000,
		        ignoreCouchBaseTimeouts : true,				
		    	bucket:"default",
		    	username:"",
		    	password:"",
		    	servers:"127.0.0.1:8091"
		    }
		}
	}
}

```



## Usage
You can read more about using this module here: https://github.com/ColdBox/cachebox-couchbase/wiki

********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
####HONOR GOES TO GOD ABOVE ALL
Because of His grace, this project exists. If you don't like this, then don't read it, its not for you.

>"Therefore being justified by faith, we have peace with God through our Lord Jesus Christ:
By whom also we have access by faith into this grace wherein we stand, and rejoice in hope of the glory of God.
And not only so, but we glory in tribulations also: knowing that tribulation worketh patience;
And patience, experience; and experience, hope:
And hope maketh not ashamed; because the love of God is shed abroad in our hearts by the 
Holy Ghost which is given unto us. ." Romans 5:5

###THE DAILY BREAD
 > "I am the way, and the truth, and the life; no one comes to the Father, but by me (JESUS)" Jn 14:1-12