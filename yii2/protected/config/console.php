<?php

// This is the configuration for yiic console application.
// Any writable CConsoleApplication properties can be configured here.
return array(
	'basePath'=>dirname(__FILE__).DIRECTORY_SEPARATOR.'..',
	'name'=>'My Console Application',

	// preloading 'log' component
	'preload'=>array('log'),
          
         'import' => array(
             'application.models.*',
             'application.workers.*',
             'application.components.*',
          ),
          
	// application components
	'components'=>array(

		// database settings are configured in database.php
		//'db'=>require(dirname(__FILE__).'/database.php'),

		'log'=>array(
			'class'=>'CLogRouter',
			'routes'=>array(
				array(
					'class'=>'CFileLogRoute',
					'levels'=>'error, warning',
				),
			),
		),
 //cach2 
                'cache' => array (
                        'class' =>'ext.redis.CRedisCache',
                        'servers' =>array(
                                 array(
                                    'host' => '10.96.142.108',
                                     'port' => 6379,
                                 ),
                         ),
                  ),
 // redis 
                 'redis' => array(
                          'class' => 'ext.redis.CRedisCache',
                           'servers' => array(
                                   array(
                                       'host' => '10.96.142.109',
                                        'port' => 6380,
                                      ),
                               ),
                   ),
// db
              'db'=>array(
                        'class' =>'CDbConnection',
                        'connectionString' => 'oci:dbname=202.205.161.18:1521/orcl;charset=UTF8',
                        'emulatePrepare' => true,
                        'username' => 'ouchnsys',
                        'password' => 'abc123',
                 'tablePrefix' => '',
                ),
// db112
              'db112'=>array(
                        'class' =>'CDbConnection',
                        'connectionString' => 'oci:dbname=202.205.161.19:1521/orcl;charset=UTF8',
                        'emulatePrepare' => true,
                        'username' => 'ouchnsys',
                        'password' => 'abc123',
                 'tablePrefix' => '',
                ),
// db113
              'db113'=>array(
                        'class' =>'CDbConnection',
                        'connectionString' => 'oci:dbname=202.205.161.20:1521/orcl;charset=UTF8',
                        'emulatePrepare' => true,
                        'username' => 'ouchnsys',
                        'password' => 'abc123',
                 'tablePrefix' => '',
                ),
             ),
);
