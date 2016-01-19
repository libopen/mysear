<?php

/**
 * This is the model class for table "EAS_SCHROLL_STUDENT".
 *
 * The followings are the available columns in table 'EAS_SCHROLL_STUDENT':
 * @property string $STUDENTID
 * @property string $BATCHCODE
 * @property string $STUDENTCODE
 * @property string $FULLNAME
 * @property string $TCPCODE
 * @property string $LEARNINGCENTERCODE
 * @property string $CLASSCODE
 * @property string $SPYCODE
 * @property string $PROFESSIONALLEVEL
 * @property string $STUDENTTYPE
 * @property string $STUDENTCATEGORY
 * @property string $ORIGINALSUBJECT
 * @property string $ORIGINALCATEGORY
 * @property string $ENROLLMENTSTATUS
 * @property string $ADMISSIONTIME
 * @property string $CREATETIME
 */
class EAS_SCHROLL_STUDENT extends CActiveRecord
{
	/**
	 * @return string the associated database table name
	 */
	public function tableName()
	{
		return 'EAS_SCHROLL_STUDENT';
	}

	/**
	 * @return array validation rules for model attributes.
	 */
	public function rules()
	{
		// NOTE: you should only define rules for those attributes that
		// will receive user inputs.
		return array(
			array('STUDENTCODE, FULLNAME', 'required'),
			array('BATCHCODE', 'length', 'max'=>6),
			array('STUDENTCODE', 'length', 'max'=>20),
			array('FULLNAME', 'length', 'max'=>80),
			array('TCPCODE, CLASSCODE, SPYCODE', 'length', 'max'=>15),
			array('LEARNINGCENTERCODE, ORIGINALSUBJECT', 'length', 'max'=>10),
			array('PROFESSIONALLEVEL, STUDENTTYPE, ENROLLMENTSTATUS', 'length', 'max'=>2),
			array('STUDENTCATEGORY, ORIGINALCATEGORY', 'length', 'max'=>5),
			array('ADMISSIONTIME, CREATETIME', 'safe'),
			// The following rule is used by search().
			// @todo Please remove those attributes that should not be searched.
			array('STUDENTID, BATCHCODE, STUDENTCODE, FULLNAME, TCPCODE, LEARNINGCENTERCODE, CLASSCODE, SPYCODE, PROFESSIONALLEVEL, STUDENTTYPE, STUDENTCATEGORY, ORIGINALSUBJECT, ORIGINALCATEGORY, ENROLLMENTSTATUS, ADMISSIONTIME, CREATETIME', 'safe', 'on'=>'search'),
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
		);
	}

	/**
	 * @return array customized attribute labels (name=>label)
	 */
	public function attributeLabels()
	{
		return array(
			'STUDENTID' => '学生编号',
			'BATCHCODE' => '年度学期',
			'STUDENTCODE' => '学号',
			'FULLNAME' => '姓名',
			'TCPCODE' => 'TCPCode',
			'LEARNINGCENTERCODE' => '学习中心',
			'CLASSCODE' => '班级代码',
			'SPYCODE' => '专业代码
EAS_SPY_BasicInfo/SpyCode',
			'PROFESSIONALLEVEL' => '专业层次代码
Dic_EAS_ProfessionalLevel',
			'STUDENTTYPE' => '学生类型代码
Dic_EAS_StudentType',
			'STUDENTCATEGORY' => 'Dic_EAS_StudentCategory',
			'ORIGINALSUBJECT' => 'Dic_EAS_Subject',
			'ORIGINALCATEGORY' => 'EAS_Dic_CourseCategories
 ',
			'ENROLLMENTSTATUS' => '学籍状态
Dic_EAS_SchoolRoll',
			'ADMISSIONTIME' => '入学时间',
			'CREATETIME' => '创建时间',
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

		$criteria->compare('STUDENTID',$this->STUDENTID,true);
		$criteria->compare('BATCHCODE',$this->BATCHCODE,true);
		$criteria->compare('STUDENTCODE',$this->STUDENTCODE,true);
		$criteria->compare('FULLNAME',$this->FULLNAME,true);
		$criteria->compare('TCPCODE',$this->TCPCODE,true);
		$criteria->compare('LEARNINGCENTERCODE',$this->LEARNINGCENTERCODE,true);
		$criteria->compare('CLASSCODE',$this->CLASSCODE,true);
		$criteria->compare('SPYCODE',$this->SPYCODE,true);
		$criteria->compare('PROFESSIONALLEVEL',$this->PROFESSIONALLEVEL,true);
		$criteria->compare('STUDENTTYPE',$this->STUDENTTYPE,true);
		$criteria->compare('STUDENTCATEGORY',$this->STUDENTCATEGORY,true);
		$criteria->compare('ORIGINALSUBJECT',$this->ORIGINALSUBJECT,true);
		$criteria->compare('ORIGINALCATEGORY',$this->ORIGINALCATEGORY,true);
		$criteria->compare('ENROLLMENTSTATUS',$this->ENROLLMENTSTATUS,true);
		$criteria->compare('ADMISSIONTIME',$this->ADMISSIONTIME,true);
		$criteria->compare('CREATETIME',$this->CREATETIME,true);

		return new CActiveDataProvider($this, array(
			'criteria'=>$criteria,
		));
	}


          public function getDbConnection()
	{
	      return Yii::app()->db;
	}

	/**
	 * Returns the static model of the specified AR class.
	 * Please note that you should have this exact method in all your CActiveRecord descendants!
	 * @param string $className active record class name.
	 * @return EAS_SCHROLL_STUDENT the static model class
	 */
	public static function model($className=__CLASS__)
	{
		return parent::model($className);
	}

    function getSchrollBatchCode()
    {
        $sql = "SELECT DISTINCT ESS.BATCHCODE, ETR.RECRUITBATCHNAME FROM EAS_SCHROLL_STUDENT ESS
                LEFT JOIN EAS_TCP_RECRUITBATCH ETR ON ETR.BATCHCODE = ESS.BATCHCODE
                WHERE ESS.LEARNINGCENTERCODE = '1200202'
                AND ESS.ENROLLMENTSTATUS = 1
                ORDER BY ESS.BATCHCODE DESC";
        $data = Yii::app()->db->createCommand($sql)->queryAll();
        return $data;

    }

     /**
     * 获取某学习某个学生的选课信息
     * @return mixed
     */
    function getStudent($orgCode,$studentCode,$BatchCode)
    {
         $sql = "SELECT ESS.*,EOC.CLASSNAME
                FROM EAS_SCHROLL_STUDENT ESS
                INNER JOIN  EAS_ORG_CLASSINFO EOC ON EOC.BATCHCODE = ESS.BATCHCODE AND EOC.LEARNINGCENTERCODE = ESS.LEARNINGCENTERCODE AND EOC.CLASSCODE = ESS.CLASSCODE
                WHERE   ESS.LEARNINGCENTERCODE = '$orgCode' AND STUDENTCODE = '$studentCode' AND ESS.ENROLLMENTSTATUS =1
                ORDER BY ESS.FULLNAME";

        $data = Yii::app()->db->createCommand($sql)->queryRow();
        return $data;

    }



      /**
     * 获取某学习中心学生选课信息汇总列表信，并带分页信息
     * @param array $params
     * @param int $offset
     * @param $limit
     * @param $currentPage
     * @return mixed
     */
    function getSchRollStudentClassInfoList(array $params, $offset=0, $limit=-1, $currentPage = -1)
    {
       // echo '11';die;
        //当前用户机构信息
        $user = Yii::app()->user->getState('userOrg');
        $orgCode= $user['orgCode'];


        //将$_GET参数过滤，根据需要重新组成查询条件
        $paramArr = array();
        $BatchCode = null;
        $fields = null;

        if(!empty($params))
        {
            foreach($params as $key=>$val)
            {
                if($key == 'page')
                {
                    continue;
                }
                if(!empty($val) )
                {
                    switch($key)
                    {
                        case 'BatchCode':
                            $BatchCode = $val;
                            break;

                        case 'FULLNAME':
                            $paramArr[] = "ESS.$key like '%$val%'";
                            break;
                        default:
                            $paramArr[] = "ESS.$key = $val";
                            break;
                    }
                }
            }
            $fields = implode(' and ', $paramArr);
        }
        //echo $fields;die;
        if(empty($fields))$fields = '1 = 1';
        //多表关联查询语句：
        $sql = "SELECT ESS.STUDENTCODE,ESS.FULLNAME,ESS.CLASSCODE,EOC.CLASSNAME,ESS.TCPCODE
                FROM  EAS_SCHROLL_STUDENT ESS
                INNER JOIN EAS_ORG_CLASSINFO EOC ON EOC.BATCHCODE = ESS.BATCHCODE AND EOC.LEARNINGCENTERCODE = ESS.LEARNINGCENTERCODE AND EOC.CLASSCODE = ESS.CLASSCODE
                WHERE   ESS.LEARNINGCENTERCODE = '$orgCode' AND ESS.ENROLLMENTSTATUS =1
                AND $fields
                ORDER BY ESS.FULLNAME";
               // echo $sql;die;
        $criteria=new CDbCriteria();
        //获取总记录数
        $result = Yii::app()->db->createCommand($sql)->queryAll();

        $pages=new CPagination(count($result));
        //$pages=new CPagination(count($result));
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

        $data = Yii::app()->db->createCommand($tempSql)->queryAll();
         //进行分库的学生选课表查询相关数据
        $connection = fcommon::choiceDbConnection();


        //echo '<pre>';print_r($data);die;
        foreach($data as $key => $val)
        {

           //学生选课总数
           $total = $this -> getTotalCourse($orgCode,$val['STUDENTCODE'],$BatchCode);
           $data[$key]['TOTAL'] = count($total);

           //规则内选课数
           $isPlan = $this -> getisPlanCourse($orgCode,$val['STUDENTCODE'],$BatchCode);
           $data[$key]['ISPLAN'] = count($isPlan);

           //已确认选课数
           $confirmState = $this -> getconfirmStateCourse($orgCode,$val['STUDENTCODE'],$BatchCode);
           $data[$key]['CONFIRMSTATE'] = count($confirmState);
        }
            //echo '<pre>';print_r($data);die;
        $result['data'] = $data;
        $result['pages'] = $pages;
        $result['count'] = $pages->getItemCount();
        return $result;
    }

    //获取学生选课数据
     function getTotalCourse($orgCode,$studentCode,$BatchCode)
    {
         //进行分库的学生选课表查询相关数据
         $connection = fcommon::choiceDbConnection();
         $totalSql = "SELECT EES.*
                       FROM EAS_ELC_STUDENTELCINFO EES
                       WHERE EES.LEARNINGCENTERCODE = '$orgCode'
                       AND EES.STUDENTCODE = '$studentCode'
                       AND EES.BATCHCODE = '$BatchCode'
                       ";
                       //echo $totalSql;die;
        $data = $connection->createCommand($totalSql)->queryAll();
        return $data;

    }


    //获取学生规则内选课数据
     function getisPlanCourse($orgCode,$studentCode,$BatchCode)
    {
         //进行分库的学生选课表查询相关数据
         $connection = fcommon::choiceDbConnection();
         $isPlanSql = "SELECT EES.*
                       FROM EAS_ELC_STUDENTELCINFO EES
                       WHERE EES.LEARNINGCENTERCODE = '$orgCode'
                       AND EES.STUDENTCODE = '$studentCode'
                       AND EES.BATCHCODE = '$BatchCode'
                       AND EES.ISPLAN = 1
                       ";
        $data = $connection->createCommand($isPlanSql)->queryAll();
        return $data;
    }

    //获取学生已确认选课数据
     function getconfirmStateCourse($orgCode,$studentCode,$BatchCode)
    {
         //进行分库的学生选课表查询相关数据
         $connection = fcommon::choiceDbConnection();
         $confirmStateSql = "SELECT EES.*
                       FROM EAS_ELC_STUDENTELCINFO EES
                       WHERE EES.LEARNINGCENTERCODE = '$orgCode'
                       AND EES.STUDENTCODE = '$studentCode'
                       AND EES.BATCHCODE = '$BatchCode'
                       AND EES.CONFIRMSTATE = 1
                       ";
        $data = $connection->createCommand($confirmStateSql)->queryAll();
        return $data;
    }




    /**
     * 获取学生信号构成的字符串a,b,c查找学生详细信息
     * @param $orgCode
     * @param $studentList
     * @return mixed
     */
    function getStudentDetailInfo($orgCode, $studentList)
    {
        //学生信息
        $studentSql = "SELECT ESS.BATCHCODE, ESS.STUDENTCODE, ESS.FULLNAME, ESS.TCPCODE, ESS.CLASSCODE,
            ESSB.GENDER, ESSB.MYPHONE, ESSB.EMAIL, EOC.CLASSNAME
            FROM EAS_SCHROLL_STUDENT ESS
            LEFT JOIN EAS_ORG_CLASSINFO EOC ON EOC.CLASSCODE = ESS.CLASSCODE
            LEFT JOIN EAS_SCHROLL_STUDENTBASICINFO ESSB ON ESSB.STUDENTCODE = ESS.STUDENTCODE
            WHERE ESS.LEARNINGCENTERCODE = '$orgCode' AND ESS.STUDENTCODE IN ($studentList)
            ORDER BY ESS.STUDENTCODE";
        $studentData = Yii::app()->db->createCommand($studentSql)->queryAll();
        return $studentData;
    }



     /**
     * 获取分院下所有学生信息
     * @param array $params
     * @param int $offset
     * @param $limit
     * @param $currentPage
     * @return mixed
     */
    function getSchRollStudentList(array $params, $offset=0, $limit=-1, $currentPage = -1)
    {

        //将$_GET参数过滤，根据需要重新组成查询条件
        $paramArr = array();

        $fields = null;

        if(!empty($params))
        {


            foreach($params as $key=>$val)
            {
                if($key == 'page')
                {
                    continue;
                }


				if(!empty($val))
                {
                    switch($key)
                    {

						case 'REASONCODES':

								if($val == '11' || $val == '26' || $$val == '42')
								{
									$paramArr[] = "ESS.PROFESSIONALLEVEL in ('2','3')";
								}
								else if($val == '22')
								{
									$paramArr[] = "ESSB.ETHNIC != '01' ";
								}
								else
								{

									$age = " AND ESSB.DocumentType = 0 AND SUBSTR ((TO_CHAR (ESS.ADMISSIONTIME,'YYYYMMDD') - SUBSTR (ESSB.IDNUMBER, 7, 8)),1,2) >= 40";
								}


                            break;
						case 'StudentTypes':
					        $paramArr[]  = "ESS.STUDENTTYPE = '$val'";
                            break;
						case 'ProfessionalLevels':
					        $paramArr[]  = "ESS.PROFESSIONALLEVEL = '$val'";
                            break;
						case 'SpyCodes':
					        $paramArr[]  = "ESS.SPYCODE = '$val'";
                            break;
						case 'LEARNINGCENTERCODES':
					        $paramArr[]  = "ESS.LEARNINGCENTERCODE like '%$val%'";
                            break;
						case 'CLASSNAME':
					        $paramArr[]  = "EOC.CLASSNAME like '%$val%'";
                            break;
						case 'IDNumber':
					        $paramArr[]  = "ESSB.IDNUMBER like '%$val%'";
                            break;
						case 'FULLNAME':
					        $paramArr[]  = "ESS.FULLNAME like '%$val%'";
                            break;
						case 'ENROLLMENTSTATUS':
					        $paramArr[]  = "ESS.ENROLLMENTSTATUS = '$val'";
                            break;

                        default:
						    $paramArr[]  = "ESS.$key = '$val'";

                            break;
                    }
                }








            }
            $fields = implode(' and ', $paramArr);
        }
        //echo '<pre>';print_r($params);die;
        if(empty($fields))$fields = '1 = 1 ';

        //多表关联查询语句：
        $sql = " SELECT ESS.STUDENTID,ESS.STUDENTCODE,ESS.FULLNAME,ESS.STUDENTTYPE,ESS.LEARNINGCENTERCODE,ESS.BATCHCODE,ESS.CLASSCODE,EOC.CLASSNAME,ESS.PROFESSIONALLEVEL,ESB.SPYNAME
				FROM EAS_SCHROLL_STUDENT ESS
                LEFT JOIN EAS_ORG_CLASSINFO EOC ON EOC.CLASSCODE = ESS.CLASSCODE
                LEFT JOIN EAS_SCHROLL_STUDENTBASICINFO   ESSB ON ESSB.STUDENTCODE = ESS.STUDENTCODE
                LEFT JOIN  	EAS_SPY_BASICINFO ESB ON ESB.SPYCODE = ESS.SPYCODE
                WHERE $fields $age

               ";
			 //echo $sql;die;
        $criteria=new CDbCriteria();

        //获取总记录数

        $result = Yii::app()->db->createCommand($sql)->queryAll();
//echo '<pre>';print_r($result);die;
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

        $data = Yii::app()->db->createCommand($tempSql)->queryAll();


        $results['data'] = $data;
        $results['pages'] = $pages;
        $results['count'] = $pages->getItemCount();
        return $results;
    }

    /**
     * @functionname:getOneStudentInfo
     * @descriptor：获取某一学生的详细信息
     * @author:pengy
     * @date:2015-1-12 15:39
     * @param $studentCode
     * @return CDbDataReader|mixed
     */
    function getOneStudentInfo($studentCode)
    {
        $sql = "SELECT ESS.*, ESSB.GENDER, ESSB.ETHNIC, ESSB.POLITICSSTATUS, ESSB.HOMETOWN, ESSB.BIRTHDATE, ESSB.EDUCATION, ESSB.MYPHONE, ESSB.DOCUMENTTYPE, ESSB.IDCARD,
                EOBL.ORGANIZATIONNAME AS LEARNINGCENTERNAME, EOBC.ORGANIZATIONNAME AS COLLEGENAME, EOBS.ORGANIZATIONNAME AS SEGMENTNAME, CASE  WHEN ESB.SPYDIRECTION IS NULL THEN ESB.SPYNAME ELSE CONCAT( ESB.SPYNAME, '(' || ESB.SPYDIRECTION || ')' ) END AS SPYNAME, EOC.CLASSNAME
                FROM EAS_SCHROLL_STUDENT ESS
                LEFT JOIN EAS_SCHROLL_STUDENTBASICINFO ESSB ON ESSB.STUDENTID = ESS.STUDENTID AND ESSB.STUDENTCODE = ESS.STUDENTCODE
                LEFT JOIN EAS_ORG_BASICINFO EOBL ON EOBL.ORGANIZATIONCODE = ESS.LEARNINGCENTERCODE
                LEFT JOIN EAS_ORG_BASICINFO EOBC ON EOBC.ORGANIZATIONCODE = SUBSTR(ESS.LEARNINGCENTERCODE,1,5)
                LEFT JOIN EAS_ORG_BASICINFO EOBS ON EOBS.ORGANIZATIONCODE = SUBSTR(ESS.LEARNINGCENTERCODE,1,3)
                LEFT JOIN EAS_SPY_BASICINFO ESB ON ESB.SPYCODE = ESS.SPYCODE
                LEFT JOIN EAS_ORG_CLASSINFO EOC ON EOC.LEARNINGCENTERCODE = ESS.LEARNINGCENTERCODE AND EOC.CLASSCODE = ESS.CLASSCODE
                WHERE ESS.STUDENTCODE = '$studentCode'";
		//echo $sql;die;
        $result = Yii::app()->db->createCommand($sql)->queryRow();
        return $result;
    }

    /**
     * @functionname:getOneStudentChangeDetailInfo
     * @descriptor：获得某学生学籍异动的详细信息
     * @author:pengy
     * @date:2015-1-22 14:36
     * @param $sn
     * @return CDbDataReader|mixed
     */
    function getOneStudentChangeDetailInfo($sn)
    {
        $sql = "SELECT ESC.*, ESCA.ATTACHMENT, ESCA.FILELOCATION, ESS.*, ESSB.GENDER, ESSB.ETHNIC, ESSB.POLITICSSTATUS, ESSB.HOMETOWN, ESSB.BIRTHDATE, ESSB.EDUCATION,
                ESSB.MYPHONE, ESSB.DOCUMENTTYPE, ESSB.IDCARD,CASE  WHEN ESB.SPYDIRECTION IS NULL THEN ESB.SPYNAME ELSE CONCAT(ESB.SPYNAME, '(' || ESB.SPYDIRECTION || ')' ) END AS SPYNAME,
                EOC.CLASSNAME,CASE  WHEN ESBN.SPYDIRECTION IS NULL THEN ESBN.SPYNAME ELSE CONCAT(ESBN.SPYNAME, '(' || ESBN.SPYDIRECTION || ')' ) END AS NEWSPYNAME, EOCN.CLASSNAME AS NEWCLASSNAME
                FROM EAS_SCHROLL_CHANGESCHROLL ESC
                LEFT JOIN EAS_SCHROLL_CHANGESCHATTACH ESCA ON ESCA.SN = ESC.SN
                LEFT JOIN EAS_SCHROLL_STUDENT ESS ON ESS.STUDENTCODE = ESC.STUDENTCODE
                LEFT JOIN EAS_SCHROLL_STUDENTBASICINFO ESSB ON ESSB.STUDENTID = ESS.STUDENTID AND ESSB.STUDENTCODE = ESS.STUDENTCODE
                LEFT JOIN EAS_SPY_BASICINFO ESB ON ESB.SPYCODE = ESS.SPYCODE
                LEFT JOIN EAS_ORG_CLASSINFO EOC ON EOC.LEARNINGCENTERCODE = ESS.LEARNINGCENTERCODE AND EOC.CLASSCODE = ESS.CLASSCODE
                LEFT JOIN EAS_SPY_BASICINFO ESBN ON ESBN.SPYCODE = ESC.IN_SPYCODE
                LEFT JOIN EAS_ORG_CLASSINFO EOCN ON EOCN.CLASSCODE = ESC.IN_CLASSCODE
                WHERE ESC.SN = '$sn'";
        $result = Yii::app()->db->createCommand($sql)->queryRow();
        return $result;
    }

    /**
     * @functionname:getOneChangeAuditInfo
     * @descriptor：获取某学籍异动申请记录所对应的所有级别审核记录
     * @author:pengy
     * @date:2015-10-13 10:00
     * @param $sn
     * @return CDbDataReader|mixed
     */
    function getOneChangeAuditInfo($sn)
    {
        $sql = "SELECT ESA.ORGCODE,ESA.AUDITOR,ESA.AUDITSTATE,ESA.AUDITOPINION,ESA.AUDITDATE
                FROM EAS_SCHROLL_CHANGEAUDIT ESA
                WHERE (ESA.ORGCODE,ESA.AUDITSTATE)IN(
                SELECT ESC.ORGCODE,MAX(ESC.AUDITSTATE)
                FROM EAS_SCHROLL_CHANGEAUDIT ESC
                GROUP BY ESC.ORGCODE)
                AND ESA.SN='$sn'";
        $result = Yii::app()->db->createCommand($sql)->queryAll();
        return $result;
    }
    //导入查询导入数据是否存在
    function getImport($sn){
        //$name=trim($name);
        $sql="SELECT 	ESS.FULLNAME,
            ESSB.GENDER,
            ESSB.BIRTHDATE,
            ESSB.DOCUMENTTYPE,
            ESSB.IDCARD,
            ESSB.ETHNIC,
            ESSB.EDUCATION,
            ESSB.ORIGINALSPY,
            ESS.ORIGINALCATEGORY,
            ESS.ORIGINALSUBJECT,
            ESL.DICNAME,
            ESS.STUDENTCODE,
            ESS.LEARNINGCENTERCODE,
            ESS.CLASSCODE,
            ESS.STUDENTID
            FROM EAS_SCHROLL_STUDENT ESS
            LEFT JOIN EAS_SCHROLL_STUDENTBASICINFO ESSB ON ESSB.STUDENTCODE = ESS.STUDENTCODE
            LEFT JOIN EAS_DIC_PROFESSIONALLEVEL ESL ON ESS.PROFESSIONALLEVEL=ESL.DICCODE
            WHERE ESS.STUDENTCODE = ".$sn." ";
            //echo $sql;die;
            $result = Yii::app()->db->createCommand($sql)->queryRow();
            return $result;
    }
}
