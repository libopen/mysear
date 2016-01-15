<?php

class MyComposeScore extends EAS_EXMM_COMPOSESCORE {
         public static $server_name = 'db';
         public static $master_db;
         
         public function getDbConnection() {
             self::$master_db = Yii::app()->{self::$server_name};
             if (self::$master_db instanceof CDbConnection) {
               self::$master_db->setActive(true);
               return self::$master_db;
             }
             else
               throw new CDbException(Yii::t('Yii','Active Record requires a "db" CDbConnection application component.'));
        }


}



