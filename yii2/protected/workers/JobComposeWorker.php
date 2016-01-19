<?php
//worker which receive studentcode then update studentcoursestatus

class JobComposeWorker extends GearmanWorker {
       public $job;
       private $args;

       public function ChangeCompose($job) {
           $this->job = $job;
           $workload = $this->job->workload();
           echo "Received job UpdateStudentStatus:".$this->job->handle()."\n";
           $this->args = CJSON::decode($workload,false);
           // do update
           $studentcode = isset($this->args->studentcode)?$this->args->studentcode:'';
           $segmentcode = isset($this->args->segmentcode)?$this->args->segmentcode:'';
           echo "paramenter studentcode:".$studentcode." segmentcode:".$segmentcode."\n";
           if (!empty($studentcode) && !empty($segmentcode)){
                echo date("y-m-d H:i:s")." begin update ".$studentcode."\n";
                $this->UpdateStudentStatus($studentcode,$segmentcode);
           }
        }


            
            private function UpdateStudentStatus($studentcode,$segmentcode){
                echo "do updateStudentStatus: ".$studentcode."-".$segmentcode."\n";
                 $servername=(int)substr($segmentcode,0,1)<4?'db112':'db113';
                 //get all studystatus 
                 EAS_ELC_STUDENTSTUDYSTATUS::$server_name=$servername;
                 EAS_ELC_STUDENTSTUDYSTATUS::getDbConnection();
                  $studentstudy = EAS_ELC_STUDENTSTUDYSTATUS::model()->findAll('STUDENTCODE=:STUDENTCODE',array(':STUDENTCODE'=>$studentcode));
                  // get suitable composescore
                   foreach($studentstudy as $row)
                   {
                        $sql=" WITH T1 AS (  SELECT STUDENTCODE, COURSEID, MAX(COMPOSESCORE)
                         MAXSCORE FROM EAS_EXMM_COMPOSESCORE WHERE STUDENTCODE='".$row->STUDENTCODE.                         "'  AND COURSEID='".$row->COURSEID."'  GROUP BY STUDENTCODE,COURSEID)
                         SELECT T2.* FROM EAS_EXMM_COMPOSESCORE T2 INNER JOIN T1 
                          ON T2.STUDENTCODE=T1.STUDENTCODE AND T2.COURSEID=T1.COURSEID AND
                           T2.COMPOSESCORE =T1.MAXSCORE
                           WHERE T2.STUDENTCODE='".$row->STUDENTCODE."' AND 
                           T2.COURSEID='".$row->COURSEID."' AND ROWNUM<2";
                            //echo $sql;
          
                             $scorerow=Yii::app()->$servername->createCommand($sql)->queryAll();
                              if (!empty($scorerow) && 
                                   ($row->SCORECODE!=$scorerow[0]['COMPOSESCORECODE']) )
                              {
                                //  print_r( $scorerow[0]['COMPOSESCORE']);
                                  $row->SCORE = $scorerow[0]['COMPOSESCORE'];
                                  $row->SCORECODE = $scorerow[0]['COMPOSESCORECODE'];
                                  $row->SCORETYPE = $scorerow[0]['EXAMUNIT'];
                                  $row->STUDYSTATUS = $scorerow[0]['COMPOSESCORE']>59?'4':'3';
                                  $row->save();
            
                              }
                     }
                   }                         


}
