<?php
class TestCommand extends CConsoleCommand
{
  public function actionIndex()
  {
      /* write to redis */
      Yii::app()->redis->set("consoletest","fdfd");
      //echo Yii::app()->redis->get("consoletest");
      Yii::app()->redis->hset('test','dd','xx');
      $mkv = array (
           'usr:0001'=>'First user',
           'usr:0002'=>'second user',
          'usr:0003'=>'third user'
      );
      //Yii::app()->redis->mset($mkv);
   //       var_dump($mkv);
       // get data from db
        
           $sql = "SELECT TCPCODE,BATCHCODE,cast(TCPNAME as varchar2(300)) TCPNAME,SPYCODE,MINGRADCREDITS,MINEXAMCREDITS,EXEMPTIONMAXCREDITS FROM EAS_TCP_GUIDANCE a WHERE BATCHCODE='201503' ";
           $rows =  Yii::app()->db->createCommand($sql)->queryAll();
            foreach($rows as $val){
                $tcpkey = $val['TCPCODE'].'010';
              /*
                 Yii::app()->redis->hset($val['TCPCODE'].'010','TCPCODE',$val['TCPCODE']);
                 Yii::app()->redis->hset($val['TCPCODE'].'010','BATCHCODE',$val['BATCHCODE']);
                 Yii::app()->redis->hset($val['TCPCODE'].'010','TCPNAME',$val['TCPNAME']);
                 Yii::app()->redis->hset($val['TCPCODE'].'010','SPYCODE',$val['SPYCODE']);
                 Yii::app()->redis->hset($val['TCPCODE'].'010','MINGRADCREDITS',$val['MINGRADCREDITS']);
                 Yii::app()->redis->hset($val['TCPCODE'].'010','MINEXAMCREDITS',$val['MINEXAMCREDITS']);
                 Yii::app()->redis->hset($val['TCPCODE'].'010','EXEMPTIONMAXCREDITS',$val['EXEMPTIONMAXCREDITS']);
          */
           //method 2 
            //$values ="'TCPCODE'=>'".$val['TCPCODE']."','BATCHCODE'=>'".$val['BATCHCODE']."','SPYCODE'=>'".$val['SPYCODE']."'";
            //echo $values;
            yii::app()->redis->del( $tcpkey);
            yii::app()->redis->hmset($tcpkey,'TCPCODE',$val['TCPCODE'],'BATCHCODE',$val['BATCHCODE'],'TCPNAME',$val['TCPNAME']);
            }  
        
 //       var_dump(Yii::app()->redis->hgetall($tcp));
           $sql = "select * from eas_org_basicinfo";
           $rows = Yii::app()->db->createCommand($sql)->queryAll();
           foreach ($rows as $val){
              }
      return 0;
  }

  public function actionState()
  {
     $products =['id'=>1,'name'=>'libin'];
     Yii::app()->cache->set('products',
                            $products,
                            30,
                            new CGlobalStateCacheDependency('version')
                          );
     print_r(Yii::app()->cache->get('products'));
     
  }
  /* get ComposeScore by CAR */
  public function actionUpdateScoreState()
  {
     /* judge which db to choice */
     EAS_EXMM_COMPOSESCORE::$server_name = 'db113';
     EAS_EXMM_COMPOSESCORE::getDbConnection();
     $composes = EAS_EXMM_COMPOSESCORE::model()->count('STUDENTCODE=:STUDENTCODE',array(':STUDENTCODE'=>'1298001416196'));
     print_r($composes);
     
  }

}
