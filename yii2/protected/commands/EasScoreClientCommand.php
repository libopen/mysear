<?php
class EasScoreClientCommand extends CConsoleCommand {

      public function actionChangeScore() {
         $client = new GearmanClient();
         $client->addServer();
         // from the redis STUDENT.SCORE.STATUS get every single record to change its score.
        Yii::log('begin work:ChangeScore','info','yii2-command-ChangeScore');
         while (Yii::app()->redis->scard('STUDENT.SCORE.STATUS')!=0){
           $studentcode = Yii::app()->redis->spop('STUDENT.SCORE.STATUS');
           if (!empty($studentcode)){
               $segmentcode = Yii::app()->redis->hget('STUDENT.'.$studentcode,'SEGMENTCODE');
               $params = CJSON::encode(array('studentcode'=>$studentcode,'segmentcode'=>$segmentcode));
               //composeScoreChange is name of register of gearman by funciton addFunction
               $handle = $client->do('composeScoreChange',$params);
          } else {
                 break;
          }
         }
         yii::log('end work:ChangeScore','info','yii2-command-changeScore');
        // $params = CJSON::encode(array('studentcode'=>'0721101200003','segmentcode'=>'211'));
         //composeScoreChange is name of register of gearman by funciton addFunction
        // $handle = $client->do('composeScoreChange',$params);
       }
}

