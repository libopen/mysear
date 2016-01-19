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

 public function actionLoadData($learningcentercode){
      $criteria = new CDbCriteria;
      $criteria->select='studentcode';
      $criteria->condition='learningcentercode=:learningcentercode';
      $criteria->params = array(':learningcentercode'=>$learningcentercode);
      $students = EAS_SCHROLL_STUDENT::model()->findAll($criteria);
      foreach($students as $row){
          Yii::app()->redis->hset('STUDENT.'.$row->STUDENTCODE,'SEGMENTCODE',substr($learningcentercode,0,3));
          // use set not list for not allow duplicate
         // Yii::app()->redis->lpush('STUDENT.SCORE.STATUS',$row->STUDENTCODE);
          Yii::app()->redis->sadd('STUDENT.SCORE.STATUS',$row->STUDENTCODE);
      }
     //  $first = Yii::app()->redis->lpop('STUDENT.SCORE.STATUS');
     //  $first = 'STUDENT.'.$first.'.STATUS';
     //  echo( Yii::app()->redis->llen('STUDENT.SCORE.STATUS'));
 }

  // to test what is get when the set is empty ,so that is 1
  public function actionTestRedisSet(){
    //echo (empty(yii::app()->redis->spop('a')));
    $studentcode = Yii::app()->redis->spop('a');
    if (!empty($studentcode)){
        echo(Yii::app()->redis->hget('STUDENT.'.$studentcode,'SEGMENTCODE'));
    }
    
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
    // print_r($composes);
     //get students
   $segmentcode='211';
   $studentcode='0721101200004';
    $servername=(int)substr($segmentcode,0,1)<4?'db112':'db113';
    //print_r($servername);
     EAS_ELC_STUDENTSTUDYSTATUS::$server_name=$servername;
     EAS_ELC_STUDENTSTUDYSTATUS::getDbConnection();
    $studentstudy = EAS_ELC_STUDENTSTUDYSTATUS::model()->findAll('STUDENTCODE=:STUDENTCODE',array(':STUDENTCODE'=>$studentcode));
     foreach($studentstudy as $row)
     {
         $sql=" WITH T1 AS (  SELECT STUDENTCODE, COURSEID, MAX(COMPOSESCORE) MAXSCORE FROM EAS_EXMM_COMPOSESCORE WHERE STUDENTCODE='".$row->STUDENTCODE."'  AND COURSEID='".$row->COURSEID."'  GROUP BY STUDENTCODE,COURSEID)
  SELECT T2.* FROM EAS_EXMM_COMPOSESCORE T2 INNER JOIN T1 ON T2.STUDENTCODE=T1.STUDENTCODE AND T2.COURSEID=T1.COURSEID AND T2.COMPOSESCORE =T1.MAXSCORE
  WHERE T2.STUDENTCODE='".$row->STUDENTCODE."' AND T2.COURSEID='".$row->COURSEID."' AND ROWNUM<2";
          //echo $sql;
         
         $scorerow=Yii::app()->$servername->createCommand($sql)->queryAll();
         if (!empty($scorerow))
         {
           // print_r( $scorerow[0]['COMPOSESCORE']);
            $row->SCORE = $scorerow[0]['COMPOSESCORE'];
                                  $row->SCORECODE = $scorerow[0]['COMPOSESCORECODE'];
                                  $row->SCORETYPE = $scorerow[0]['EXAMUNIT'];
                                  $row->STUDYSTATUS = $scorerow[0]['COMPOSESCORE']>59?'4':'3';
                                  $row->save();

         }
        // $composes = EAS_EXMM_COMPOSESCORE::model()->findAllBySql($sql);
        //   if (!empty($composes))
        //   {
         //    print_r($composes);
        //  }

     }
  }

}
