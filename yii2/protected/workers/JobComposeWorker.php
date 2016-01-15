<?php
//worker which receive studentcode then update studentcoursestatus

class JobComposeWorker extends GearmanWorker {
       public $job;
       private $args;

       public function ChangeCompose($job) {
           $this->job = $job;
           $workload = $this->job->workload();
           echo "Received job UpdateStudentStatus:".$this->job->handle()."\n";
           $this->args = cJSON::decode($workload,false);
           // do update
           $studentcode = isset($this->args->studentcode)?$this->args->studentcode:'';
           $segmentcode = isset($this->args->segmentcode)?$this->args->segmentcode:'';
           echo "paramenter studentcode:".$studentcode." segmentcode:".$segmentcode."\n";
           if (!empty($studentcode) && !empty($segmentcode)){
                echo " begin update ".$studentcode."\n";
                $this->UpdateStudentStatus($studentcode,$segmentcode);
           }
        }



            private function UpdateStudentStatus($studentcode,$segmentcode){
                echo "do updateStudentStatus".$studentcode."-".$segmentcode."\n";
            }
}
