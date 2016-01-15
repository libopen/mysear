<?php


class EasScoreCommand extends CConsoleCommand {
     public function run($args){
         $worker = new JobComposeWorker();
         $worker->addServers();
         $worker->addFunction("composeScoreChange",array($worker,"ChangeCompose"));
         while(1) {
            print "waiting for job....\n";
           $ret = $worker->work();
           if ($worker->returnCode() != GEARMAN_SUCCESS)
              break;
            }
         }
}
