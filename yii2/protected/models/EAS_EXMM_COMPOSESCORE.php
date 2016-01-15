<?php

/**
 * This is the model class for table "EAS_EXMM_COMPOSESCORE".
 *
 * The followings are the available columns in table 'EAS_EXMM_COMPOSESCORE':
 * @property integer $SN
 * @property string $EXAMPLANCODE
 * @property string $EXAMCATEGORYCODE
 * @property string $EXAMUNIT
 * @property string $COURSEID
 * @property string $EXAMPAPERCODE
 * @property string $SEGMENTCODE
 * @property string $COLLEGECODE
 * @property string $LEARNINGCENTERCODE
 * @property string $CLASSCODE
 * @property string $STUDENTCODE
 * @property double $PAPERSCORE
 * @property string $PAPERSCORECODE
 * @property double $PAPERSCALE
 * @property integer $PAPER_SN
 * @property double $XKSCORE
 * @property string $XKSCORECODE
 * @property double $XKSCALE
 * @property integer $XK_SN
 * @property double $MIDTERMSCORE
 * @property string $MIDTERMSCORECODE
 * @property double $MIDTERMSCALE
 * @property double $COMPOSESCORE
 * @property double $COMPOSESCORECODE
 * @property string $COMPOSEDATE
 * @property string $ASSESSMODE
 * @property integer $ISCOMPLEX
 * @property integer $NUMSIGNUP
 * @property integer $ISPUBLISH
 * @property string $PUBLISHDATE
 *
 * The followings are the available model relations:
 * @property EASEXMMXKSCORE $xKSN
 * @property EASEXMMPAPERSCORE $pAPERSN
 */
class EAS_EXMM_COMPOSESCORE extends CActiveRecord
{
        public $total=0;
               public static $server_name = 'db';
         public static $master_db;
        /**
	 * @return string the associated database table name
	 */
	public function tableName()
	{
		return 'EAS_EXMM_COMPOSESCORE';
	}

	/**
	 * @return array validation rules for model attributes.
	 */
	public function rules()
	{
		// NOTE: you should only define rules for those attributes that
		// will receive user inputs.
		return array(
			array('PAPER_SN, XK_SN, ISCOMPLEX, NUMSIGNUP, ISPUBLISH', 'numerical', 'integerOnly'=>true),
			array('PAPERSCORE, PAPERSCALE, XKSCORE, XKSCALE, MIDTERMSCORE, MIDTERMSCALE, COMPOSESCORE, COMPOSESCORECODE', 'numerical'),
			array('EXAMPLANCODE, STUDENTCODE', 'length', 'max'=>20),
			array('EXAMCATEGORYCODE', 'length', 'max'=>3),
			array('EXAMUNIT', 'length', 'max'=>100),
			array('COURSEID, EXAMPAPERCODE, SEGMENTCODE, LEARNINGCENTERCODE, PAPERSCORECODE, XKSCORECODE, MIDTERMSCORECODE', 'length', 'max'=>10),
			array('COLLEGECODE, CLASSCODE', 'length', 'max'=>15),
			array('ASSESSMODE', 'length', 'max'=>2),
			array('COMPOSEDATE, PUBLISHDATE', 'safe'),
			// The following rule is used by search().
			// @todo Please remove those attributes that should not be searched.
			array('SN, EXAMPLANCODE, EXAMCATEGORYCODE, EXAMUNIT, COURSEID, EXAMPAPERCODE, SEGMENTCODE, COLLEGECODE, LEARNINGCENTERCODE, CLASSCODE, STUDENTCODE, PAPERSCORE, PAPERSCORECODE, PAPERSCALE, PAPER_SN, XKSCORE, XKSCORECODE, XKSCALE, XK_SN, MIDTERMSCORE, MIDTERMSCORECODE, MIDTERMSCALE, COMPOSESCORE, COMPOSESCORECODE, COMPOSEDATE, ASSESSMODE, ISCOMPLEX, NUMSIGNUP, ISPUBLISH, PUBLISHDATE', 'safe', 'on'=>'search'),
		);
	}

	/**
	 * @return array relational rules.
	 */
	public function relations()
	{
		// NOTE: you may need to adjust the relation name and the related
		// class name for the relations automatically generated below.
		return array(
			'xKSN' => array(self::BELONGS_TO, 'EASEXMMXKSCORE', 'XK_SN'),
			'pAPERSN' => array(self::BELONGS_TO, 'EASEXMMPAPERSCORE', 'PAPER_SN'),
		);
	}

	/**
	 * @return array customized attribute labels (name=>label)
	 */
	public function attributeLabels()
	{
		return array(
			'SN' => 'Sn',
			'EXAMPLANCODE' => 'Examplancode',
			'EXAMCATEGORYCODE' => 'Examcategorycode',
			'EXAMUNIT' => 'Examunit',
			'COURSEID' => 'Courseid',
			'EXAMPAPERCODE' => 'Exampapercode',
			'SEGMENTCODE' => 'Segmentcode',
			'COLLEGECODE' => 'Collegecode',
			'LEARNINGCENTERCODE' => 'Learningcentercode',
			'CLASSCODE' => 'Classcode',
			'STUDENTCODE' => 'Studentcode',
			'PAPERSCORE' => 'Paperscore',
			'PAPERSCORECODE' => 'Paperscorecode',
			'PAPERSCALE' => 'Paperscale',
			'PAPER_SN' => 'Paper Sn',
			'XKSCORE' => 'Xkscore',
			'XKSCORECODE' => 'Xkscorecode',
			'XKSCALE' => 'Xkscale',
			'XK_SN' => 'Xk Sn',
			'MIDTERMSCORE' => 'Midtermscore',
			'MIDTERMSCORECODE' => 'Midtermscorecode',
			'MIDTERMSCALE' => 'Midtermscale',
			'COMPOSESCORE' => 'Composescore',
			'COMPOSESCORECODE' => 'Composescorecode',
			'COMPOSEDATE' => 'Composedate',
			'ASSESSMODE' => '1纸考
2机考',
			'ISCOMPLEX' => 'Iscomplex',
			'NUMSIGNUP' => 'Numsignup',
			'ISPUBLISH' => 'Ispublish',
			'PUBLISHDATE' => 'Publishdate',
		);
	}

	/**
	 * Retrieves a list of models based on the current search/filter conditions.
	 *
	 * Typical usecase:
	 * - Initialize the model fields with values from filter form.
	 * - Execute this method to get CActiveDataProvider instance which will filter
	 * models according to data in model fields.
	 * - Pass data provider to CGridView, CListView or any similar widget.
	 *
	 * @return CActiveDataProvider the data provider that can return the models
	 * based on the search/filter conditions.
	 */
	public function search()
	{
		// @todo Please modify the following code to remove attributes that should not be searched.

		$criteria=new CDbCriteria;

		$criteria->compare('SN',$this->SN);
		$criteria->compare('EXAMPLANCODE',$this->EXAMPLANCODE,true);
		$criteria->compare('EXAMCATEGORYCODE',$this->EXAMCATEGORYCODE,true);
		$criteria->compare('EXAMUNIT',$this->EXAMUNIT,true);
		$criteria->compare('COURSEID',$this->COURSEID,true);
		$criteria->compare('EXAMPAPERCODE',$this->EXAMPAPERCODE,true);
		$criteria->compare('SEGMENTCODE',$this->SEGMENTCODE,true);
		$criteria->compare('COLLEGECODE',$this->COLLEGECODE,true);
		$criteria->compare('LEARNINGCENTERCODE',$this->LEARNINGCENTERCODE,true);
		$criteria->compare('CLASSCODE',$this->CLASSCODE,true);
		$criteria->compare('STUDENTCODE',$this->STUDENTCODE,true);
		$criteria->compare('PAPERSCORE',$this->PAPERSCORE);
		$criteria->compare('PAPERSCORECODE',$this->PAPERSCORECODE,true);
		$criteria->compare('PAPERSCALE',$this->PAPERSCALE);
		$criteria->compare('PAPER_SN',$this->PAPER_SN);
		$criteria->compare('XKSCORE',$this->XKSCORE);
		$criteria->compare('XKSCORECODE',$this->XKSCORECODE,true);
		$criteria->compare('XKSCALE',$this->XKSCALE);
		$criteria->compare('XK_SN',$this->XK_SN);
		$criteria->compare('MIDTERMSCORE',$this->MIDTERMSCORE);
		$criteria->compare('MIDTERMSCORECODE',$this->MIDTERMSCORECODE,true);
		$criteria->compare('MIDTERMSCALE',$this->MIDTERMSCALE);
		$criteria->compare('COMPOSESCORE',$this->COMPOSESCORE);
		$criteria->compare('COMPOSESCORECODE',$this->COMPOSESCORECODE);
		$criteria->compare('COMPOSEDATE',$this->COMPOSEDATE,true);
		$criteria->compare('ASSESSMODE',$this->ASSESSMODE,true);
		$criteria->compare('ISCOMPLEX',$this->ISCOMPLEX);
		$criteria->compare('NUMSIGNUP',$this->NUMSIGNUP);
		$criteria->compare('ISPUBLISH',$this->ISPUBLISH);
		$criteria->compare('PUBLISHDATE',$this->PUBLISHDATE,true);

		return new CActiveDataProvider($this, array(
			'criteria'=>$criteria,
		));
	}

	/**
	 * @return CDbConnection the database connection used for this class
	 */
	public function getDbConnection()
	{
	      //return Yii::app()->db112;
             self::$master_db = Yii::app()->{self::$server_name};
             if (self::$master_db instanceof CDbConnection) {
               self::$master_db->setActive(true);
               return self::$master_db;
             }
             else
               throw new CDbException(Yii::t('Yii','Active Record requires a "db" CDbConnection application component.'));
	}

	/**
	 * Returns the static model of the specified AR class.
	 * Please note that you should have this exact method in all your CActiveRecord descendants!
	 * @param string $className active record class name.
	 * @return EAS_EXMM_COMPOSESCORE the static model class
	 */
	public static function model($className=__CLASS__)
	{
		return parent::model($className);
	}



        //分部综合成绩信息
        public function searchList($params){
            $connection = fcommon::choiceDbConnection();
            $results = array();
            $condition = "IsPublish=1 and Compose.SegmentCode='".$params['orgCode']."'";
            if($params['sn']!='')
            {
                $ROW=EAS_EXMM_DEFINITION::model()->findByPk($params['sn']);
                $condition .= " and Compose.EXAMPLANCODE =".$ROW['EXAMPLANCODE'];
            }
            if($params['examCategoryCode']!='')$condition .= " and Compose.EXAMCATEGORYCODE = '".$params['examCategoryCode']."' ";
            if($params['segmentCode']!='' )$condition .= " and Compose.SEGMENTCODE ='".$params['segmentCode']."'";
            if($params['examPaperName']!='')$condition .= " and subject.EXAMPAPERNAME like '%".$params['examPaperName']."%'";
            if($params['examPaperCode']!='')$condition .= " and Compose.EXAMPAPERCODE =".$params['examPaperCode'];
            if($params['collegeCode']!='')$condition .= " and Compose.COLLEGECODE ='".$params['collegeCode']."'";
            if($params['learningCenterCode']!='')$condition .= " and Compose.LEARNINGCENTERCODE ='".$params['learningCenterCode']."'";
            if($params['studentCode']!='')$condition .= " and Compose.studentCode ='".$params['studentCode']."'";
            if($params['fullName']!='')$condition .= " and student.fullName ='".$params['fullName']."'";
            $orderBy = " ORDER BY Compose.ExamPaperCode,Compose.STUDENTCODE, Compose.COMPOSEDATE,ComposeAlter.MAINTAINDATE DESC";
            //获取数据总数
            $sqlForCount = "select count(1)
                FROM  EAS_ExmM_ComposeScore Compose
                LEFT JOIN ouchnsys.EAS_EXMM_SUBJECTPLAN@ouchnbase subject on subject.ExamPaperCode=Compose.ExamPaperCode and subject.EXAMPLANCODE=Compose.EXAMPLANCODE
                where $condition";
            $res = $connection->createCommand($sqlForCount)->queryColumn();
            //初始化分页类
            $this->total = $res[0] ;
            $startNum = ($params['currentPage']-1)*$params['pageSize'];
            $endNum = $startNum + $params['pageSize'];
            $sql="select Compose.SN,define.EXAMPLANNAME,EEC.EXAMCATEGORY,Compose.IsPublish, Compose.XkScore  , Compose.PaperScore,Compose.ExamPaperCode ,subject.ExamPaperName,Compose.studentCode,student.fullName,Compose.CollegeCode,Compose.LearningCenterCode
                ,Compose.ComposeScore,Compose.ComposeDate
                ,ComposeAlter.XkScoreNew,ComposeAlter.PaperScoreNew,ComposeAlter.ComposeScoreNew,ComposeAlter.Maintainer,ComposeAlter.MaintainDate,ComposeAlter.AuditSate
                FROM  EAS_ExmM_ComposeScore Compose
                left join EAS_ExmM_ComposeScoreAlter ComposeAlter on Compose.SN=ComposeAlter.SN
                LEFT JOIN ouchnsys.EAS_EXMM_EXAMCATEGORY@ouchnbase EEC ON EEC.EXAMCATEGORYCODE = Compose.EXAMCATEGORYCODE AND EEC.SEGMENTCODE IN ('010','".$params['orgCode']."')
                LEFT JOIN ouchnsys.EAS_EXMM_DEFINITION@ouchnbase define on Compose.ExamPlanCode = define.ExamPlanCode and define.CreateOrgCode in ('010','".$params['orgCode']."')
                LEFT JOIN ouchnsys.EAS_SchRoll_Student@ouchnbase student on student.studentCode = Compose.studentCode
                LEFT JOIN ouchnsys.EAS_EXMM_SUBJECTPLAN@ouchnbase subject on subject.ExamPaperCode=Compose.ExamPaperCode and subject.EXAMPLANCODE=Compose.EXAMPLANCODE
                where $condition $orderBy
                ";
            $sqlForPage = "select * from (
                            select tempTable.*,rownum as rownum_  from (
                                                            $sql
                                                                ) tempTable
                         where  rownum <= $endNum)
                        where rownum_ > $startNum";
            $data = $connection->createCommand($sqlForPage)->queryAll();
            return $data;
        }

        public function getComposeScoreInfo($SN,$orgCode,$condition=0){
            $connection = fcommon::choiceDbConnection();
            $sql="select Compose.SN,define.EXAMPLANNAME,EEC.EXAMCATEGORY,Compose.ExamPaperCode ,subject.ExamPaperName,Compose.studentCode,student.fullName,Compose.SegmentCode,Compose.CollegeCode,Compose.LearningCenterCode
                , Compose.XkScore  ,Compose.XkScoreCode, Compose.XkScale,Compose.PaperScore, PaperScoreCode, PaperScale,Compose.ComposeScore,Compose.ComposeScoreCode,Compose.COMPOSEDATE
                ,ComposeAlter.XkScoreNew,ComposeAlter.XkScoreCodeNew,ComposeAlter.PaperScoreNew,ComposeAlter.PaperScoreCodeNew,ComposeAlter.ComposeScoreNew,ComposeAlter.ComposeScoreCodeNew,ComposeAlter.Maintainer,ComposeAlter.MaintainDate,ComposeAlter.AuditSate,ComposeAlter.Reason
                ,ComposeAlter.CENTERTAUDITOR,ComposeAlter.CENTERAUDITCONTENT,ComposeAlter.CENTERAUDITDATE
                FROM  EAS_ExmM_ComposeScore Compose

                LEFT JOIN ouchnsys.EAS_EXMM_EXAMCATEGORY@ouchnbase EEC ON EEC.EXAMCATEGORYCODE = Compose.EXAMCATEGORYCODE AND EEC.SEGMENTCODE IN ('010','".$orgCode."')
                LEFT JOIN ouchnsys.EAS_EXMM_DEFINITION@ouchnbase define on Compose.ExamPlanCode = define.ExamPlanCode and define.CreateOrgCode in ('010','".$orgCode."')
                LEFT JOIN ouchnsys.EAS_SchRoll_Student@ouchnbase student on student.studentCode = Compose.studentCode
                LEFT JOIN ouchnsys.EAS_EXMM_SUBJECTPLAN@ouchnbase subject on subject.ExamPaperCode=Compose.ExamPaperCode and subject.EXAMPLANCODE=Compose.EXAMPLANCODE
                left join EAS_ExmM_ComposeScoreAlter ComposeAlter on Compose.SN=ComposeAlter.SN ";

            if($condition==1) $sql.= "and ComposeAlter.AuditSate !=4  where Compose.SN='".$SN."' ";
            else $sql.=" where Compose.SN='".$SN."' ";
            $sql .= "order by ComposeAlter.MAINTAINDATE DESC";
            $data = $connection->createCommand($sql)->queryAll();
            return $data;
        }

        //获取成绩代码
        public function getScoreCode(){
            $data1 =array();
            $sql="select * from EAS_DIC_SCORECODE";
            $data = Yii::app()->db->createCommand($sql)->queryAll();
            foreach ($data as $row){
                $data1[$row['DICCODE']]=$row;
            }
            return $data1;
        }
        //成绩更动保存
        public function ChangeSave($params){
            $connection = fcommon::choiceDbConnection();
            $ScoreCodeDic= $this->getScoreCode();

            $countSql ="select CAlter.SN,Compose.XkScale , Compose.PaperScale  from EAS_ExmM_ComposeScoreAlter CAlter
                            left join EAS_ExmM_ComposeScore  Compose
                            on Compose.SN=CAlter.SN
                            where CAlter.SN='".$params['SN']."' and CAlter.AuditSate !=4";
            $arr=$connection->createCommand($countSql)->queryRow();
            //zk:2015-09-18 无论是否需要总部审核，都在成绩更动记录中记录此次修改
            $audit = ($params['ISHQAUDIT'] == 0) ? 4 : 0;   //不需要审核时

            //if($params['ISHQAUDIT']==1){//需要总部审核
                if(is_array($arr)){  //修改没有审核通过的成绩更动记录
                    $sql ="update EAS_ExmM_ComposeScoreAlter set XkScoreNew='".$ScoreCodeDic[$params['XkScoreCodeNew']]['DICSCORE']."' , XkScoreCodeNew='".$params['XkScoreCodeNew']."' , PaperScoreNew='".$ScoreCodeDic[$params['PaperScoreCodeNew']]['DICSCORE']."' ,PaperScoreCodeNew='".$params['PaperScoreCodeNew']."' ,
                            ComposeScoreCodeNew='".$params['ComposeScoreCodeNew']."' , ComposeScoreNew='".$params['ComposeScoreNew']."'
                            where SN='".$params['SN']."' and AuditSate !=4";
                }else{//创建新的成绩更动记录
                    $countSql ="select count(1) as count  from EAS_ExmM_ComposeScoreAlter CAlter
                            where CAlter.SN='".$params['SN']."' ";

                    $num=$connection->createCommand($countSql)->queryColumn();
					$ComposeScoreSql =  "select * from EAS_ExmM_ComposeScore  where SN= '".$params['SN']."'";
					$ComposeScoreInfo=$connection->createCommand($ComposeScoreSql)->queryRow();

                    $sql = "INSERT INTO EAS_ExmM_ComposeScoreAlter
							(SN,EXAMPLANCODE,EXAMCATEGORYCODE,EXAMUNIT,COURSEID,EXAMPAPERCODE,SEGMENTCODE,COLLEGECODE,LEARNINGCENTERCODE,CLASSCODE,STUDENTCODE,ALTERNUMBER,
							PAPERSCOREOLD,PAPERSCORECODEOLD,XKSCOREOLD,XKSCORECODEOLD,COMPLEXSCOREOLD,COMPLEXSCORECODEOLD,PAPERSCORENEW,PAPERSCORECODENEW,XKSCORENEW,XKSCORECODENEW,COMPOSESCORENEW,COMPOSESCORECODENEW,
							REASON,MAINTAINDATE,MAINTAINER,AUDITSATE,CENTERAUDITSTATE,CENTERAUDITCONTENT,CENTERAUDITDATE,CENTERTAUDITOR)
								VALUES
								(
									".$ComposeScoreInfo['SN'].",
									'".$ComposeScoreInfo['EXAMPLANCODE']."',
									'".$ComposeScoreInfo['EXAMCATEGORYCODE']."',
									'".$ComposeScoreInfo['EXAMUNIT']."',
									'".$ComposeScoreInfo['COURSEID']."',
									'".$ComposeScoreInfo['EXAMPAPERCODE']."',
									'".$ComposeScoreInfo['SEGMENTCODE']."',
									'".$ComposeScoreInfo['COLLEGECODE']."',
									'".$ComposeScoreInfo['LEARNINGCENTERCODE']."',
									'".$ComposeScoreInfo['CLASSCODE']."',
									'".$ComposeScoreInfo['STUDENTCODE']."',
									$num[0],
									'".$ComposeScoreInfo['PAPERSCORE']."',
									'".$ComposeScoreInfo['PAPERSCORECODE']."',
									'".$ComposeScoreInfo['XKSCORE']."',
									'".$ComposeScoreInfo['XKSCORECODE']."',
									'".$ComposeScoreInfo['COMPOSESCORE']."',
									'".$ComposeScoreInfo['COMPOSESCORECODE']."',
									'".$ScoreCodeDic[$params['PaperScoreCodeNew']]['DICSCORE']."',
									'".$params['PaperScoreCodeNew']."',
									'".$ScoreCodeDic[$params['XkScoreCodeNew']]['DICSCORE']."',
									'".$params['XkScoreCodeNew']."',
									'".$params['ComposeScoreNew']."',
									'".$params['ComposeScoreCodeNew']."',
									'".$params['Reason']."',
									sysdate,
									'".fcommon::getLoginUser()."',
									$audit,
									'',
									'',
									'',
									''
								)
									";
						//echo $sql;die;


                }
            //}

            if($params['ISHQAUDIT'] == 0)
            {//不需要总部审核  直接修改 成绩合成表
                $tmpSql="update EAS_ExmM_ComposeScore set XkScore='".$ScoreCodeDic[$params['XkScoreCodeNew']]['DICSCORE']."' , XkScoreCode='".$params['XkScoreCodeNew']."' , PaperScore='".$ScoreCodeDic[$params['PaperScoreCodeNew']]['DICSCORE']."' , PaperScoreCode='".$params['PaperScoreCodeNew']."',
                      ComposeScoreCode='".$params['ComposeScoreCodeNew']."' , ComposeScore='".$params['ComposeScoreNew']."'
                      where SN='".$params['SN']."'";

                $connection->createCommand($tmpSql)->execute();
            }

            return $connection->createCommand($sql)->execute();
        }

	/**
	 * 校验考试成绩录入权限（纸考）
	 * User: jiakd
	 * Date: 14-12-10
	 * Time: 下午15:54
    */

	function IsAllowEntry(){

	   $arr = Yii::app()->user->getState('userOrg');
	   $SEGMENTCODE = substr($arr['orgCode'],0,3);
	   $orgLevel = $arr['orgLevel'];
	   $dbtool = dbtools::single();
	   if($orgLevel==2){return true;}  // 如果是分部 默认 允许
	   if($orgLevel==3){
	       $table = 'EAS_EXMM_COLENTRYSCORERULE';
		   $sql = "select IsAllowEntryExam from {$table} where collegecode='{$arr['orgCode']}' and segmentcode='{$SEGMENTCODE}'";
	   }else if($orgLevel==4){
	       $table = 'EAS_EXMM_LEARNENTRYSCORERULE';
		   $sql = "select IsAllowEntryExam from {$table} where LearningCenterCode='{$arr['orgCode']}' and segmentcode='{$SEGMENTCODE}'";
	   }

	   $row = $dbtool->selectlimit($sql);
       $flag = $row[0]['ISALLOWENTRYEXAM'];
	   if($flag==1){

		   return true;
	   }
	   return false;




	}

	/**
	 * 统计考试录入人数录入的人数
	 * @param string $EXAMPLANCODE 考试定义代码.
	 * @param string $EXAMPLANCODE 分部代码.
	 * @param string $EXAMPAPERCODE 试卷号.
	 * @return $arr   0，总人数 ,1，已录入人数 ,2,未录入人数
	 */
	function getScoreNum($EXAMPLANCODE,$SEGMENTCODE,$EXAMPAPERCODE){


		$dbtool = dbtools::single();
		$obj = EAS_EXMM_COMPOSESCORE::model();
		$arr = Yii::app()->user->getState('userOrg');
	    $filter['EXAMPLANCODE'] = $EXAMPLANCODE;
		$filter['SEGMENTCODE'] = $SEGMENTCODE;
		$filter['EXAMPAPERCODE'] = $EXAMPAPERCODE;
		$filter['LEARNINGCENTERCODE|head'] = $arr['orgCode'];
		$where = $dbtool->filter($obj,$filter);



    $sql = "SELECT
	COUNT(*) AS total,
	SUM(DECODE(ISENTRYPASS, 1, 0, 1)) AS noscorenum,
SUM(DECODE(ISENTRYPASS, 1, 1, 0)) AS scorenum
FROM
	EAS_EXMM_PAPERSCORE where ";
	$sql .= $where;
	 $sql .="group by exampapercode";
		 $data = $dbtool->selectlimitbydb($sql,$limit,$offset,$SEGMENTCODE);
		return $data[0];




	}

    /**
     * 分部-综合成绩合成的统计情况
     * @param array $params
     * @param int $offset
     * @param $limit
     * @param $currentPage
     * @return mixed
     * @author:pengy
     */
    function getComposeScoreTotalList(array $params, $offset=0, $limit=-1, $currentPage = -1)
    {
        //将$_GET参数过滤，根据需要重新组成查询条件
        $paramArr = array();
        $fields = null;
        if(!empty($params))
        {
            foreach($params as $key=>$val)
            {
                if(($key == 'page') || ($key == 'option') || ($key == 'examPlanName'))
                {
                    continue;
                }
                if(!empty($val) || $val == '0')
                {
                    switch($key)
                    {
                        case 'type':
                            empty($val) ? $paramArr[] = 'EXKS.SCORE IS NULL' : $paramArr[] = 'EXKS.SCORE >= 0';
                            break;
                        case 'sn':
                            $paramArr[] = "ESU.EXAMPLANCODE = (SELECT EED.EXAMPLANCODE FROM ouchnsys.EAS_EXMM_DEFINITION@ouchnbase EED WHERE EED.SN = '$val')";
                            break;
                        case 'examPaperName':
                            $paramArr[] = "ESP.$key LIKE '%$val%'";
                            break;
                        case 'examPaperCode':
                            $paramArr[] = "ESP.$key LIKE '%$val%'";
                            break;
                        case 'segmentCode':
                            $currentOrg = $val;
                            break;
                        default:
                            $paramArr[] = "ESU.$key = '$val'";
                            break;
                    }
                }
            }
            $fields = implode(' and ', $paramArr);
        }

        if(empty($fields))$fields = '1 = 1';
        $connection = fcommon::choiceDbConnection();
        //多表关联查询语句
        $sql = "SELECT EED.SN AS EXAMPLANSN, ECS.EXAMUNIT,ESU.EXAMPLANCODE, EED.EXAMPLANNAME, ESU.EXAMCATEGORYCODE, ESC.EXAMCATEGORY, ESP.EXAMPAPERCODE, ESP.EXAMPAPERNAME, COUNT(ESU.SN) AS SIGNCOUNT, SUM(DECODE(ECS.ISCOMPLEX,1,1,0)) AS COMPLEXCOUNT,
                SUM(DECODE(ECS.ISCOMPLEX,0,1,0)) AS NOTCOMPLEXCOUNT,SUM(DECODE(ECS.ISPUBLISH,1,1,0)) AS PUBLISHCOUNT, SUM(DECODE(ECS.ISPUBLISH,0,1,0)) AS NOTPUBLISHCOUNT,
                TO_CHAR(wmsys.wm_concat(ECS.SN)) ALLSN
                FROM EAS_EXMM_SIGNUP ESU
                LEFT JOIN EAS_EXMM_COMPOSESCORE ECS ON ECS.SIGN_SN = ESU.SN
                LEFT JOIN ouchnsys.EAS_EXMM_DEFINITION@ouchnbase EED ON EED.EXAMPLANCODE = ESU.EXAMPLANCODE AND EED.CREATEORGCODE IN ('010','$currentOrg')
                LEFT JOIN ouchnsys.EAS_EXMM_SUBJECTPLAN@ouchnbase ESP ON ESP.EXAMPLANCODE=ESU.EXAMPLANCODE AND ESP.EXAMCATEGORYCODE=ESU.EXAMCATEGORYCODE AND ESP.EXAMPAPERCODE=ESU.EXAMPAPERCODE AND ESP.SEGMENTCODE IN ('010','$currentOrg')
                LEFT JOIN ouchnsys.EAS_EXMM_EXAMCATEGORY@ouchnbase ESC ON ESC.EXAMCATEGORYCODE = ESU.EXAMCATEGORYCODE AND ESC.SEGMENTCODE IN ('010','$currentOrg')
                WHERE ESU.ISCONFIRM = 1
                AND ESU.SEGMENTCODE = '$currentOrg'
                AND ECS.SN IS NOT NULL
                AND $fields
                GROUP BY EED.SN, ESU.EXAMPLANCODE,  EED.EXAMPLANNAME, ESU.EXAMCATEGORYCODE, ESC.EXAMCATEGORY, ESP.EXAMPAPERCODE, ESP.EXAMPAPERNAME,ECS.EXAMUNIT
                ORDER BY ESU.EXAMPLANCODE, ESU.EXAMCATEGORYCODE, ESP.EXAMPAPERCODE";

        $criteria=new CDbCriteria();
        //获取总记录数
        $result = $connection->createCommand($sql)->queryAll();
        $pages=new CPagination(count($result));
        if($currentPage != -1)
        {
            $pages->currentPage = $currentPage;
        }
        $limit == -1 ? $pages->pageSize = 20 : $pages->pageSize = $limit ;
        $pages->applyLimit($criteria);

        //分页查询数据
        $startNum = $pages->currentPage*$pages->pageSize;
        $endNum = $startNum + $pages->pageSize;
        $tempSql = "SELECT * FROM (SELECT tempTable.*, rownum as rownum_ FROM ($sql)tempTable WHERE rownum <= $endNum)row_ WHERE rownum_ >$startNum";
        $data = $connection->createCommand($tempSql)->queryAll();

        $results['data'] = $data;
        $results['pages'] = $pages;
        $results['count'] = $pages->getItemCount();
        return $results;
    }

    /**
     * 分部-综合成绩合成中各个弹出框的信息的统计情况
     * @param array $params
     * @param int $offset
     * @param $limit
     * @param $currentPage
     * @return mixed
     * @author:pengy
     */
    function getComposeScoreDetailInfoList(array $params, $offset=0, $limit=-1, $currentPage = -1)
    {
        //将$_GET参数过滤，根据需要重新组成查询条件
        $paramArr = array();
        $fields = null;
        if(!empty($params))
        {
            foreach($params as $key=>$val)
            {
                if(($key == 'page') || ($key == 'option'))
                {
                    continue;
                }
                if(!empty($val) || $val == '0')
                {
                    switch($key)
                    {
                        case 'type':
                            switch($val)
                            {
                                case 'complex':
                                    $paramArr[] = "ECS.ISCOMPLEX = 1";
                                    break;
                                case 'notcomplex':
                                    $paramArr[] = "ECS.ISCOMPLEX = 0";
                                    break;
                                case 'publish':
                                    $paramArr[] = "ECS.ISPUBLISH = 1";
                                    break;
                                case 'notpublish':
                                    $paramArr[] = "ECS.ISPUBLISH = 0";
                                    break;
                            }
                            break;
                        case 'currentOrg':
                            $currentOrg = $val;
                            break;
                        case 'dialog_examPaperCode':
                            $temp = explode('_', $key);
                            $useKey = $temp[1];
                            $paramArr[] = "ECS.$useKey LIKE '%$val%'";
                            break;
                        case 'dialog_examPaperName':
                            $temp = explode('_', $key);
                            $useKey = $temp[1];
                            $paramArr[] = "ESP.$useKey LIKE '%$val%'";
                            break;
                        case 'dialog_classCode':
                            $temp = explode('_', $key);
                            $useKey = $temp[1];
                            $paramArr[] = "ECS.$useKey LIKE '%$val%'";
                            break;
                        case 'dialog_className':
                            $temp = explode('_', $key);
                            $useKey = $temp[1];
                            $paramArr[] = "EOC.$useKey LIKE '%$val%'";
                            break;
                        default:
                            $temp = explode('_', $key);
                            $useKey = $temp[1];
                            $paramArr[] = "ECS.$useKey = '$val'";
                            break;
                    }
                }
            }
            $fields = implode(' and ', $paramArr);
        }

        if(empty($fields))$fields = '1 = 1';
        $connection = fcommon::choiceDbConnection();
        //多表关联查询语句
        $sql = "SELECT ECS.*, EOC.CLASSNAME, ESP.EXAMPAPERNAME, ESS.FULLNAME, ESC.EXAMCATEGORY, EOB.ORGANIZATIONNAME AS COLLEGENAME, EOB2.ORGANIZATIONNAME AS LEARNINGCENTERNAME,
                EXKSP.XKSCALE AS USEXKSCALE, EXKSP.PAPERSCALE AS USEPAPERSCALE
                FROM EAS_EXMM_SIGNUP ESU
                LEFT JOIN EAS_EXMM_COMPOSESCORE ECS ON ECS.SIGN_SN = ESU.SN
                LEFT JOIN ouchnsys.EAS_EXMM_XKSTANDARDPLAN@ouchnbase EXKSP ON EXKSP.SN = ECS.XKP_SN
                LEFT JOIN ouchnsys.EAS_SCHROLL_STUDENT@ouchnbase ESS ON ESS.STUDENTCODE = ESU.STUDENTCODE AND ESS.CLASSCODE = ESU.CLASSCODE
                LEFT JOIN ouchnsys.EAS_ORG_BASICINFO@ouchnbase EOB ON EOB.ORGANIZATIONCODE = ESU.COLLEGECODE AND EOB.ORGANIZATIONTYPE = 3
                LEFT JOIN ouchnsys.EAS_ORG_BASICINFO@ouchnbase EOB2 ON EOB2.ORGANIZATIONCODE = ESU.LEARNINGCENTERCODE AND EOB2.ORGANIZATIONTYPE = 4
                LEFT JOIN ouchnsys.EAS_EXMM_SUBJECTPLAN@ouchnbase ESP ON ESP.EXAMPLANCODE=ESU.EXAMPLANCODE AND ESP.EXAMCATEGORYCODE=ESU.EXAMCATEGORYCODE AND ESP.EXAMPAPERCODE=ESU.EXAMPAPERCODE AND ESP.SEGMENTCODE IN ('010','$currentOrg')
                LEFT JOIN ouchnsys.EAS_EXMM_EXAMCATEGORY@ouchnbase ESC ON ESC.EXAMCATEGORYCODE = ESU.EXAMCATEGORYCODE AND ESC.SEGMENTCODE IN ('010','$currentOrg')
                LEFT JOIN ouchnsys.EAS_ORG_CLASSINFO@ouchnbase EOC ON EOC.CLASSCODE = ECS.CLASSCODE AND EOC.LEARNINGCENTERCODE = ECS.LEARNINGCENTERCODE
                WHERE ESU.ISCONFIRM = 1
                AND ECS.SN IS NOT NULL
                AND $fields
                ORDER BY ESU.EXAMPLANCODE, ESU.EXAMCATEGORYCODE, ESP.EXAMPAPERCODE, ESU.STUDENTCODE";

        $criteria=new CDbCriteria();
        //获取总记录数
        $result = $connection->createCommand($sql)->queryAll();
        $pages=new CPagination(count($result));
        if($currentPage != -1)
        {
            $pages->currentPage = $currentPage;
        }
        $limit == -1 ? $pages->pageSize = 20 : $pages->pageSize = $limit ;
        $pages->applyLimit($criteria);

        //分页查询数据
        $startNum = $pages->currentPage*$pages->pageSize;
        $endNum = $startNum + $pages->pageSize;
        $tempSql = "SELECT * FROM (SELECT tempTable.*, rownum as rownum_ FROM ($sql)tempTable WHERE rownum <= $endNum)row_ WHERE rownum_ >$startNum";
        $data = $connection->createCommand($tempSql)->queryAll();

        $results['data'] = $data;
        $results['pages'] = $pages;
        $results['count'] = $pages->getItemCount();
        return $results;
    }



	/**
     * 考试成绩统计（按考试人数）
     * @author:lijz
     * @param array $params
     * @param int $offset
     * @param $limit
     * @param $currentPage
     * @return mixed
     */
    function getExamScoreStatisticPeopleNumberList(array $params, $offset=0, $limit=-1, $currentPage = -1)
    {
        //将$_GET参数过滤，根据需要重新组成查询条件
        $paramArr = array();
	    $fields = null;

        if(!empty($params))
        {
            foreach($params as $key=>$val)
            {
                if($key == 'page' || $key == 'exportFlag')
                {
                    continue;
                }
                if(!empty($val) || ($val == '0'))
                {
                    switch($key)
                    {
						case 'examPlanCode':
							$definition=EAS_EXMM_DEFINITION::model()->findByPk($val);;
						    $paramArr[]  = "eecs.$key = '$definition[EXAMPLANCODE]' ";
							$examPlanCode = $definition['EXAMPLANCODE'];
                            break;

					   case 'SegmentCode':
							$codeArr = implode(',', $val);
						    $paramArr[]  = "eecs.SegmentCode  in ($codeArr)";
                            break;
                       case 'ExamPaperCode':
					        $paramArr[]  = "eecs.EXAMPAPERCODE LIKE '%$val%'";

                            break;
						case 'ExamPaperName':
					        $paramArr[]  = "EESP.EXAMPAPERNAME LIKE '%$val%'";

                            break;
                        default:
						    $paramArr[]  = "eecs.$key = '$val'";

                            break;
                    }
                }
            }
            $fields = implode(' and ', $paramArr);



        }
        if(empty($fields))$fields = '1 = 1';

		//当前用户机构信息:orgCode所属机构代码

        $connection = fcommon::choiceDbConnection();
		//ComposeScorecode -1 缺考 -2替考  ！-1 实考 -3 作弊
		$sql = "SELECT
					eecs.segmentcode,eecs.ExamPaperCode,EESP.EXAMPAPERNAME,EOB.ORGANIZATIONNAME,
					SUM (DECODE (eecs.sn, '', 0, 1)) AS sntotal,
					SUM(CASE  WHEN eecs.ComposeScore BETWEEN   0 AND 10.99  THEN 1  ELSE 0 END) AS a,
					SUM(CASE  WHEN eecs.ComposeScore BETWEEN  11 AND 20.99  THEN 1  ELSE 0 END) AS b,
					SUM(CASE  WHEN eecs.ComposeScore BETWEEN  21 AND 30.99  THEN 1  ELSE 0 END) AS c,
					SUM(CASE  WHEN eecs.ComposeScore BETWEEN  31 AND 40.99  THEN 1  ELSE 0 END) AS d,
					SUM(CASE  WHEN eecs.ComposeScore BETWEEN  41 AND 50.99  THEN 1  ELSE 0 END) AS e,
					SUM(CASE  WHEN eecs.ComposeScore BETWEEN  51 AND 60.99  THEN 1  ELSE 0 END) AS f,
					SUM(CASE  WHEN eecs.ComposeScore BETWEEN  61 AND 70.99  THEN 1  ELSE 0 END) AS g,
					SUM(CASE  WHEN eecs.ComposeScore BETWEEN  71 AND 80.99  THEN 1  ELSE 0 END) AS h,
					SUM(CASE  WHEN eecs.ComposeScore BETWEEN  81 AND 90.99  THEN 1  ELSE 0 END) AS i,
					SUM(CASE  WHEN eecs.ComposeScore BETWEEN  91 AND 100 THEN 1  ELSE 0 END) AS j,
					SUM(CASE  WHEN eecs.ComposeScore BETWEEN  60 AND 100 THEN 1  ELSE 0 END) AS k,
					SUM(CASE  WHEN eecs.ComposeScorecode != '-1' THEN 1  ELSE 0 END) AS l,
					SUM(CASE  WHEN eecs.ComposeScorecode = '-1' THEN 1  ELSE 0 END) AS m,
					SUM(CASE  WHEN eecs.ComposeScorecode = '-2' THEN 1  ELSE 0 END) AS n，
					SUM(CASE  WHEN eecs.ComposeScorecode = '-3' THEN 1  ELSE 0 END) AS o
				FROM
				EAS_ExmM_ComposeScore eecs
				LEFT JOIN ouchnsys.EAS_ExmM_SubjectPlan@ouchnbase eesp ON eecs.ExamPlanCode = eesp.ExamPlanCode AND eecs.ExamCategoryCode = eesp.ExamCategoryCode AND eecs.ExamPaperCode = eesp.ExamPaperCode
				LEFT JOIN ouchnsys.EAS_ORG_BASICINFO@ouchnbase EOB ON eecs.SegmentCode = EOB.ORGANIZATIONCODE
				WHERE $fields
				GROUP BY eecs.segmentcode,eecs.ExamPaperCode,EESP.EXAMPAPERNAME,EOB.ORGANIZATIONNAME
				ORDER BY eecs.segmentcode,eecs.ExamPaperCode
				";

        $criteria=new CDbCriteria();
        //获取总记录数

        $result = $connection->createCommand($sql)->queryAll();
        $pages=new CPagination(count($result));
        if($currentPage != -1)
        {
            $pages->currentPage = $currentPage;
        }
        $limit == -1 ? $pages->pageSize=20 : $pages->pageSize=$limit;
        $pages->applyLimit($criteria);

        //分页查询数据
        if(isset($params['exportFlag']) && $params['exportFlag'] == '1')
        {
            $startNum = 0;
            $endNum = 99999999999;

        }else{
            $startNum = $pages->currentPage*$pages->pageSize;
            $endNum = $startNum + $pages->pageSize;
        }


        $tempSql = "SELECT * FROM (SELECT tempTable.*, rownum as rownum_ FROM ($sql)tempTable WHERE rownum <= $endNum)row_ WHERE rownum_ >$startNum";

        $data = $connection->createCommand($tempSql)->queryAll();

        $result['data'] = $data;

        $result['pages'] = $pages;
        $result['count'] = $pages->getItemCount();
        return $result;
    }


	/**
     * 考试成绩统计（按考试人次）
     * @author:lijz
     * @param array $params
     * @param int $offset
     * @param $limit
     * @param $currentPage
     * @return mixed
     */
    function getExamScoreStatisticPersonTimeList(array $params, $offset=0, $limit=-1, $currentPage = -1)
    {
        //将$_GET参数过滤，根据需要重新组成查询条件
        $paramArr = array();
        $fields = null;
        if(!empty($params))
        {
            foreach($params as $key=>$val)
            {
                if($key == 'page' || $key == 'exportFlag')
                {
                    continue;
                }
                if(!empty($val) || ($val == '0'))
                {
                    switch($key)
                    {
						case 'examPlanCode':
							$definition=EAS_EXMM_DEFINITION::model()->findByPk($val);;
						    $paramArr[]  = "eecs.$key = '$definition[EXAMPLANCODE]' ";
							$examPlanCode = $definition['EXAMPLANCODE'];
                            break;

                        default:
						    $paramArr[]  = "eecs.$key = '$val'";

                            break;
                    }
                }
            }
            $fields = implode(' and ', $paramArr);



        }
        if(empty($fields))$fields = '1 = 1';

		//当前用户机构信息:orgCode所属机构代码

        $connection = fcommon::choiceDbConnection();
		//ComposeScorecode -1 缺考 -2替考  ！-1 实考 -3 作弊
		$sql = "SELECT
					eecs.segmentcode,eecs.CollegeCode,eecs.LearningCenterCode,EOB.ORGANIZATIONNAME AS SegmentName,EOC.ORGANIZATIONNAME AS CollegeName,EOL.ORGANIZATIONNAME AS LearningCenterName,
					SUM (DECODE (eecs.sn, '', 0, 1)) AS sntotal,
					SUM(CASE  WHEN eecs.ComposeScore BETWEEN   0 AND 10.99  THEN 1  ELSE 0 END) AS a,
					SUM(CASE  WHEN eecs.ComposeScore BETWEEN  11 AND 20.99  THEN 1  ELSE 0 END) AS b,
					SUM(CASE  WHEN eecs.ComposeScore BETWEEN  21 AND 30.99  THEN 1  ELSE 0 END) AS c,
					SUM(CASE  WHEN eecs.ComposeScore BETWEEN  31 AND 40.99  THEN 1  ELSE 0 END) AS d,
					SUM(CASE  WHEN eecs.ComposeScore BETWEEN  41 AND 50.99  THEN 1  ELSE 0 END) AS e,
					SUM(CASE  WHEN eecs.ComposeScore BETWEEN  51 AND 60.99  THEN 1  ELSE 0 END) AS f,
					SUM(CASE  WHEN eecs.ComposeScore BETWEEN  61 AND 70.99  THEN 1  ELSE 0 END) AS g,
					SUM(CASE  WHEN eecs.ComposeScore BETWEEN  71 AND 80.99  THEN 1  ELSE 0 END) AS h,
					SUM(CASE  WHEN eecs.ComposeScore BETWEEN  81 AND 90.99  THEN 1  ELSE 0 END) AS i,
					SUM(CASE  WHEN eecs.ComposeScore BETWEEN  91 AND 100 THEN 1  ELSE 0 END) AS j,
					SUM(CASE  WHEN eecs.ComposeScore BETWEEN  60 AND 100 THEN 1  ELSE 0 END) AS k,
					SUM(CASE  WHEN eecs.ComposeScorecode != '-1' THEN 1  ELSE 0 END) AS l,
					SUM(CASE  WHEN eecs.ComposeScorecode = '-1' THEN 1  ELSE 0 END) AS m,
					SUM(CASE  WHEN eecs.ComposeScorecode = '-2' THEN 1  ELSE 0 END) AS n，
					SUM(CASE  WHEN eecs.ComposeScorecode = '-3' THEN 1  ELSE 0 END) AS o
				FROM
				EAS_ExmM_ComposeScore eecs
				LEFT JOIN ouchnsys.EAS_ExmM_SubjectPlan@ouchnbase eesp ON eecs.ExamPlanCode = eesp.ExamPlanCode AND eecs.ExamCategoryCode = eesp.ExamCategoryCode AND eecs.ExamPaperCode = eesp.ExamPaperCode
				LEFT JOIN ouchnsys.EAS_ORG_BASICINFO@ouchnbase EOB ON eecs.SegmentCode = EOB.ORGANIZATIONCODE
				LEFT JOIN ouchnsys.EAS_ORG_BASICINFO@ouchnbase EOC ON eecs.CollegeCode = EOC.ORGANIZATIONCODE
				LEFT JOIN ouchnsys.EAS_ORG_BASICINFO@ouchnbase EOL ON eecs.LearningCenterCode = EOL.ORGANIZATIONCODE
				WHERE $fields
				GROUP BY eecs.segmentcode,eecs.CollegeCode,eecs.LearningCenterCode,EOB.ORGANIZATIONNAME,EOC.ORGANIZATIONNAME,EOL.ORGANIZATIONNAME
				ORDER BY eecs.segmentcode,eecs.CollegeCode,eecs.LearningCenterCode
				";
				//echo $sql;die;
        $criteria=new CDbCriteria();
        //获取总记录数

        $result = $connection->createCommand($sql)->queryAll();
        $pages=new CPagination(count($result));
        if($currentPage != -1)
        {
            $pages->currentPage = $currentPage;
        }
        $limit == -1 ? $pages->pageSize=20 : $pages->pageSize=$limit;
        $pages->applyLimit($criteria);

        //分页查询数据
        if(isset($params['exportFlag']) && $params['exportFlag'] == '1')
        {
            $startNum = 0;
            $endNum = 99999999999;
        }
        else
        {
            $startNum = $pages->currentPage*$pages->pageSize;
            $endNum = $startNum + $pages->pageSize;
        }


        $tempSql = "SELECT * FROM (SELECT tempTable.*, rownum as rownum_ FROM ($sql)tempTable WHERE rownum <= $endNum)row_ WHERE rownum_ >$startNum";

        $data = $connection->createCommand($tempSql)->queryAll();

        $result['data'] = $data;

        $result['pages'] = $pages;
        $result['count'] = $pages->getItemCount();
        return $result;
    }

    /**
     * @functionname:getExamScoreStatisticBySegmentList
     * @descriptor：考试成绩统计(按分部)
     * @author:pengy
     * @date:2015-5-12 16:00
     * @param array $params
     * @param int $offset
     * @param $limit
     * @param $currentPage
     * @return mixed
     */
    function getExamScoreStatisticBySegmentList(array $params, $offset=0, $limit=-1, $currentPage = -1)
    {
        //将$_GET参数过滤，根据需要重新组成查询条件
        $paramArr112 = array();
        $paramArr113 = array();
        $fields112 = null;
        $fields113 = null;

        if(!empty($params))
        {
            foreach($params as $key=>$val)
            {
                if($key == 'page' || $key == 'exportFlag')
                {
                    continue;
                }
                if(!empty($val) || ($val == '0'))
                {
                    switch($key)
                    {
                        case 'sn':
                            $definition=EAS_EXMM_DEFINITION::model()->findByPk($val);;
                            $examPlanCode = $definition['EXAMPLANCODE'];
                            $paramArr112[]  = "EEC112.EXAMPLANCODE = '$examPlanCode'";
                            $paramArr113[]  = "EEC113.EXAMPLANCODE = '$examPlanCode'";
                            break;
                        default:
                            $paramArr112[]  = "EEC112.$key = '$val'";
                            $paramArr113[]  = "EEC113.$key = '$val'";
                            break;
                    }
                }
            }
            $fields112 = implode(' and ', $paramArr112);
            $fields113 = implode(' and ', $paramArr113);
        }
        if(empty($fields112))$fields112 = '1 = 1';
        if(empty($fields113))$fields113 = '1 = 1';

        //ComposeScorecode -1 缺考 -2替考  ！-1 实考 -3 作弊
        $sql = "SELECT EEC112.SEGMENTCODE, EOB.ORGANIZATIONNAME, SUM (DECODE (EEC112.SN, '', 0, 1)) AS TOTAL,
                SUM(CASE WHEN EEC112.ComposeScore BETWEEN 0 AND 10.99 THEN 1 ELSE 0 END) AS a,
                SUM(CASE WHEN EEC112.ComposeScore BETWEEN 11 AND 20.99 THEN 1 ELSE 0 END) AS b,
                SUM(CASE WHEN EEC112.ComposeScore BETWEEN 21 AND 30.99 THEN 1 ELSE 0 END) AS c,
                SUM(CASE WHEN EEC112.ComposeScore BETWEEN 31 AND 40.99 THEN 1 ELSE 0 END) AS d,
                SUM(CASE WHEN EEC112.ComposeScore BETWEEN 41 AND 50.99 THEN 1 ELSE 0 END) AS e,
                SUM(CASE WHEN EEC112.ComposeScore BETWEEN 51 AND 60.99 THEN 1 ELSE 0 END) AS f,
                SUM(CASE WHEN EEC112.ComposeScore BETWEEN 61 AND 70.99 THEN 1 ELSE 0 END) AS g,
                SUM(CASE WHEN EEC112.ComposeScore BETWEEN 71 AND 80.99 THEN 1 ELSE 0 END) AS h,
                SUM(CASE WHEN EEC112.ComposeScore BETWEEN 81 AND 90.99 THEN 1 ELSE 0 END) AS i,
                SUM(CASE WHEN EEC112.ComposeScore BETWEEN 91 AND 100 THEN 1 ELSE 0 END) AS j,
                SUM(CASE WHEN EEC112.ComposeScore BETWEEN 60 AND 100 THEN 1 ELSE 0 END) AS k,
                SUM(CASE WHEN EEC112.ComposeScorecode != '-1' THEN 1 ELSE 0 END) AS l,
                SUM(CASE WHEN EEC112.ComposeScorecode = '-1' THEN 1 ELSE 0 END) AS m,
                SUM(CASE WHEN EEC112.ComposeScorecode = '-2' THEN 1 ELSE 0 END) AS n,
                SUM(CASE WHEN EEC112.ComposeScorecode = '-3' THEN 1 ELSE 0 END) AS o
                FROM EAS_EXMM_COMPOSESCORE@ouchn112 EEC112
                LEFT JOIN EAS_EXMM_SUBJECTPLAN EES ON EEC112.EXAMPLANCODE = EES.EXAMPLANCODE AND EEC112.EXAMCATEGORYCODE = EES.EXAMCATEGORYCODE AND EEC112.EXAMPAPERCODE = EES.EXAMPAPERCODE
                LEFT JOIN EAS_ORG_BASICINFO EOB ON EEC112.SegmentCode = EOB.ORGANIZATIONCODE
                WHERE $fields112
                GROUP BY EEC112.SEGMENTCODE, EOB.ORGANIZATIONNAME
                UNION ALL
                SELECT EEC113.SEGMENTCODE, EOB.ORGANIZATIONNAME, SUM (DECODE (EEC113.SN, '', 0, 1)) AS TOTAL,
                SUM(CASE WHEN EEC113.ComposeScore BETWEEN 0 AND 10.99 THEN 1 ELSE 0 END) AS a,
                SUM(CASE WHEN EEC113.ComposeScore BETWEEN 11 AND 20.99 THEN 1 ELSE 0 END) AS b,
                SUM(CASE WHEN EEC113.ComposeScore BETWEEN 21 AND 30.99 THEN 1 ELSE 0 END) AS c,
                SUM(CASE WHEN EEC113.ComposeScore BETWEEN 31 AND 40.99 THEN 1 ELSE 0 END) AS d,
                SUM(CASE WHEN EEC113.ComposeScore BETWEEN 41 AND 50.99 THEN 1 ELSE 0 END) AS e,
                SUM(CASE WHEN EEC113.ComposeScore BETWEEN 51 AND 60.99 THEN 1 ELSE 0 END) AS f,
                SUM(CASE WHEN EEC113.ComposeScore BETWEEN 61 AND 70.99 THEN 1 ELSE 0 END) AS g,
                SUM(CASE WHEN EEC113.ComposeScore BETWEEN 71 AND 80.99 THEN 1 ELSE 0 END) AS h,
                SUM(CASE WHEN EEC113.ComposeScore BETWEEN 81 AND 90.99 THEN 1 ELSE 0 END) AS i,
                SUM(CASE WHEN EEC113.ComposeScore BETWEEN 91 AND 100 THEN 1 ELSE 0 END) AS j,
                SUM(CASE WHEN EEC113.ComposeScore BETWEEN 60 AND 100 THEN 1 ELSE 0 END) AS k,
                SUM(CASE WHEN EEC113.ComposeScorecode != '-1' THEN 1 ELSE 0 END) AS l,
                SUM(CASE WHEN EEC113.ComposeScorecode = '-1' THEN 1 ELSE 0 END) AS m,
                SUM(CASE WHEN EEC113.ComposeScorecode = '-2' THEN 1 ELSE 0 END) AS n,
                SUM(CASE WHEN EEC113.ComposeScorecode = '-3' THEN 1 ELSE 0 END) AS o
                FROM EAS_EXMM_COMPOSESCORE@ouchn113 EEC113
                LEFT JOIN EAS_EXMM_SUBJECTPLAN EES ON EEC113.EXAMPLANCODE = EES.EXAMPLANCODE AND EEC113.EXAMCATEGORYCODE = EES.EXAMCATEGORYCODE AND EEC113.EXAMPAPERCODE = EES.EXAMPAPERCODE
                LEFT JOIN EAS_ORG_BASICINFO EOB ON EEC113.SegmentCode = EOB.ORGANIZATIONCODE
                WHERE $fields113
                GROUP BY EEC113.SEGMENTCODE, EOB.ORGANIZATIONNAME";
        $criteria=new CDbCriteria();
        //获取总记录数

        $result = Yii::app()->db->createCommand($sql)->queryAll();
        $pages=new CPagination(count($result));
        if($currentPage != -1)
        {
            $pages->currentPage = $currentPage;
        }
        $limit == -1 ? $pages->pageSize=20 : $pages->pageSize=$limit;
        $pages->applyLimit($criteria);
        //分页查询数据
        if(isset($params['exportFlag']) && $params['exportFlag'] == '1')
        {
            $startNum = 0;
            $endNum = 99999999999;
        }
        else
        {
            $startNum = $pages->currentPage*$pages->pageSize;
            $endNum = $startNum + $pages->pageSize;
        }


        $tempSql = "SELECT * FROM (SELECT tempTable.*, rownum as rownum_ FROM ($sql)tempTable WHERE rownum <= $endNum)row_ WHERE rownum_ >$startNum";
        $data = Yii::app()->db->createCommand($tempSql)->queryAll();
        $result['data'] = $data;
        $result['pages'] = $pages;
        $result['count'] = $pages->getItemCount();
        return $result;
    }
}
