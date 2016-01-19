<?php

/**
 * This is the model class for table "EAS_ELC_STUDENTELCINFO".
 *
 * The followings are the available columns in table 'EAS_ELC_STUDENTELCINFO':
 * @property string $SN
 * @property string $BATCHCODE
 * @property string $STUDENTCODE
 * @property string $COURSEID
 * @property string $LEARNINGCENTERCODE
 * @property string $CLASSCODE
 * @property string $ISPLAN
 * @property string $OPERATOR
 * @property string $ELCSTATE
 * @property string $OPERATETIME
 * @property string $CONFIRMOPERATOR
 * @property string $CONFIRMSTATE
 * @property string $CONFIRMTIME
 * @property integer $CURRENTSELECTNUMBER
 * @property string $SPYCODE
 * @property double $REFID
 * @property double $ISAPPLYEXAM
 * @property double $ELCTYPE
 * @property string $STUDENTID
 */
class EAS_ELC_STUDENTELCINFO extends CActiveRecord
{
         public static $server_name = 'db';
         public static $master_db;
	/**
	 * @return string the associated database table name
	 */
	public function tableName()
	{
		return 'EAS_ELC_STUDENTELCINFO';
	}

	/**
	 * @return array validation rules for model attributes.
	 */
	public function rules()
	{
		// NOTE: you should only define rules for those attributes that
		// will receive user inputs.
		return array(
			array('SN', 'required'),
			array('CURRENTSELECTNUMBER', 'numerical', 'integerOnly'=>true),
			array('ISAPPLYEXAM, ELCTYPE', 'numerical'),
			array('SN', 'length', 'max'=>16),
			array('BATCHCODE', 'length', 'max'=>6),
			array('STUDENTCODE', 'length', 'max'=>20),
			array('COURSEID, LEARNINGCENTERCODE', 'length', 'max'=>10),
			array('CLASSCODE, SPYCODE', 'length', 'max'=>15),
			array('ISPLAN, ELCSTATE, CONFIRMSTATE', 'length', 'max'=>2),
			array('OPERATOR, CONFIRMOPERATOR', 'length', 'max'=>160),
			array('STUDENTID', 'length', 'max'=>40),
			array('OPERATETIME, CONFIRMTIME', 'safe'),
			// The following rule is used by search().
			// @todo Please remove those attributes that should not be searched.
			array('SN, BATCHCODE, STUDENTCODE, COURSEID, LEARNINGCENTERCODE, CLASSCODE, ISPLAN, OPERATOR, ELCSTATE, OPERATETIME, CONFIRMOPERATOR, CONFIRMSTATE, CONFIRMTIME, CURRENTSELECTNUMBER, SPYCODE, REFID, ISAPPLYEXAM, ELCTYPE, STUDENTID', 'safe', 'on'=>'search'),
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
			'SN' => '选课信息编号',
			'BATCHCODE' => '年度学期',
			'STUDENTCODE' => '学号',
			'COURSEID' => '课程编号',
			'LEARNINGCENTERCODE' => '学习中心',
			'CLASSCODE' => '班级代码',
			'ISPLAN' => '班级代码',
			'OPERATOR' => '选课操作人',
			'ELCSTATE' => '选课状态',
			'OPERATETIME' => '选课操作时间',
			'CONFIRMOPERATOR' => '确认操作人',
			'CONFIRMSTATE' => '确认状态',
			'CONFIRMTIME' => '确认操作时间',
			'CURRENTSELECTNUMBER' => 'Currentselectnumber',
			'SPYCODE' => 'Spycode',
			'REFID' => 'Refid',
			'ISAPPLYEXAM' => 'Isapplyexam',
			'ELCTYPE' => 'Elctype',
			'STUDENTID' => 'Studentid',
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

		$criteria->compare('SN',$this->SN,true);
		$criteria->compare('BATCHCODE',$this->BATCHCODE,true);
		$criteria->compare('STUDENTCODE',$this->STUDENTCODE,true);
		$criteria->compare('COURSEID',$this->COURSEID,true);
		$criteria->compare('LEARNINGCENTERCODE',$this->LEARNINGCENTERCODE,true);
		$criteria->compare('CLASSCODE',$this->CLASSCODE,true);
		$criteria->compare('ISPLAN',$this->ISPLAN,true);
		$criteria->compare('OPERATOR',$this->OPERATOR,true);
		$criteria->compare('ELCSTATE',$this->ELCSTATE,true);
		$criteria->compare('OPERATETIME',$this->OPERATETIME,true);
		$criteria->compare('CONFIRMOPERATOR',$this->CONFIRMOPERATOR,true);
		$criteria->compare('CONFIRMSTATE',$this->CONFIRMSTATE,true);
		$criteria->compare('CONFIRMTIME',$this->CONFIRMTIME,true);
		$criteria->compare('CURRENTSELECTNUMBER',$this->CURRENTSELECTNUMBER);
		$criteria->compare('SPYCODE',$this->SPYCODE,true);
		$criteria->compare('REFID',$this->REFID);
		$criteria->compare('ISAPPLYEXAM',$this->ISAPPLYEXAM);
		$criteria->compare('ELCTYPE',$this->ELCTYPE);
		$criteria->compare('STUDENTID',$this->STUDENTID,true);

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
                //return fcommon::choiceDbConnection();
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
	 * @return EAS_ELC_STUDENTELCINFO the static model class
	 */
	public static function model($className=__CLASS__)
	{
		return parent::model($className);
	}

    /**
     * 获取选课课程信息表
     * @param array $params
     * @param int $offset
     * @param $limit
     * @param $currentPage
     * @return mixed
     */
    function getLearningCenterCoursesList(array $params, $offset=0, $limit=-1, $currentPage = -1)
    {
        //当前用户机构信息
        $user = Yii::app()->user->getState('userOrg');
        $orgCode= $user['orgCode'];
        //进行分库的学生选课表查询相关数据
        $connection = fcommon::choiceDbConnection();
        //将$_GET参数过滤，根据需要重新组成查询条件
        $paramArr = array();
        $elcBatchCode = null;
        $fields = null;
        if(!empty($params))
        {
            foreach($params as $key=>$val)
            {
                if(in_array($key, array('page','type','option','exportFlag','optionType','classId')))
                {
                    continue;
                }

                if($key == 'CURRENTSELECTNUMBER')
                {
                    $val=='<>1'?$current= " AND EES.CURRENTSELECTNUMBER <> '1'" :  $current = " AND EES.CURRENTSELECTNUMBER = $val";
                    continue;
                }
                if(!empty($val) || ($val == 0))
                {
                    switch($key)
                    {
                        case 'dialogStudentCode':
                            $paramArr[] = "EES.STUDENTCODE like '%$val%'";
                            break;
                        case 'dialogCourseCode':
                            $paramArr[] = "EES.COURSEID like '%$val%'";
                            break;
                        case 'CONFIRMSTATE':
                            empty($val) ? $paramArr[] = "nvl(EES.CONFIRMSTATE,'0')<>'1'" :  $paramArr[] = "EES.$key = $val";
                            break;

                        default:
                            $paramArr[] = "EES.$key = $val";
                            break;
                    }
                }
            }
            $fields = implode(' and ', $paramArr);
        }
        //echo $fields;die;
        if(empty($fields))$fields = '1 = 1';
        if(!empty($current))
        {
            $fields .= $current;
        }
        //多表关联查询语句：
        $sql = "SELECT * FROM EAS_ELC_STUDENTELCINFO EES
                WHERE EES.LEARNINGCENTERCODE = '$orgCode'
                AND $fields
                ORDER BY EES.STUDENTCODE, EES.COURSEID";

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
        if(isset($params['exportFlag']) && $params['exportFlag'] == '1')
        {
            $startNum = 0;
            $endNum = 99999999999;
        }
        else{
            $startNum = $pages->currentPage*$pages->pageSize;
            $endNum = $startNum + $pages->pageSize;
        }


        $tempSql = "SELECT * FROM (SELECT tempTable.*, rownum as rownum_ FROM ($sql)tempTable WHERE rownum <= $endNum)row_ WHERE rownum_ >$startNum";

        $data = $connection->createCommand($tempSql)->queryAll();

        $courseIdList = '';
        $studentList = '';
        foreach($data as $key => $val)
        {
            if(++$key == count($data))
            {
                $courseIdList .= "'".$val['COURSEID']."'";
                $studentList .= "'".$val['STUDENTCODE']."'";
            }
            else
            {
                $courseIdList .= "'".$val['COURSEID']."',";
                $studentList .= "'".$val['STUDENTCODE']."',";
            }
        }
        if(!empty($courseIdList))
        {
            //课程信息
            $courseSql = "SELECT * FROM EAS_COURSE_BASICINFO ECB WHERE ECB.COURSEID IN ($courseIdList)";
            $temp_courseData = Yii::app()->db->createCommand($courseSql)->queryAll();
            $courseData = array();
            foreach($temp_courseData as $arr)
            {
                $courseData[$arr['COURSEID']] = $arr;
            }
        }
        if(!empty($studentList))
        {
            //学生信息
            $studentSql = "SELECT ESS.STUDENTCODE, ESS.FULLNAME FROM EAS_SCHROLL_STUDENT ESS WHERE ESS.STUDENTCODE IN ($studentList)";
            $temp_studentData = Yii::app()->db->createCommand($studentSql)->queryAll();

            $studentData = array();
            foreach($temp_studentData as $arr)
            {
                $studentData[$arr['STUDENTCODE']] = $arr['FULLNAME'];
            }
        }
        foreach($data as &$val)
        {
            $val['courseDetail'] = $courseData[$val['COURSEID']];
            $val['STUDENTNAME'] = $studentData[$val['STUDENTCODE']];
        }
        $result['data'] = $data;
        $result['pages'] = $pages;
        $result['count'] = $pages->getItemCount();
        return $result;
    }

    /**
     * 获取学生选课学生信息表
     * @param array $params
     * @param int $offset
     * @param $limit
     * @param $currentPage
     * @return mixed
     */
    function getLearningCenterStudentList(array $params, $offset=0, $limit=-1, $currentPage = -1)
    {
        //当前用户机构信息
        $user = Yii::app()->user->getState('userOrg');
        $orgCode= $user['orgCode'];
        //进行分库的学生选课表查询相关数据
        $connection = fcommon::choiceDbConnection();
        //将$_GET参数过滤，根据需要重新组成查询条件
        $paramArr = array();
        $elcBatchCode = null;
        $fields = null;
        $paramArr[] = "EES.LEARNINGCENTERCODE = '$orgCode'";
        if(!empty($params))
        {
            foreach($params as $key=>$val)
            {
                if($key == 'page' || $key == 'type' || $key == 'option')
                {
                    continue;
                }
                if(!empty($val) || ($val == 0))
                {
                    switch($key)
                    {
                        case 'dialogStudentCode':
                            $paramArr[] = "EES.STUDENTCODE like '%$val%'";
                            break;
                        default:
                            $paramArr[] = "EES.$key = $val";
                            break;
                    }
                }
            }
            $fields = implode(' and ', $paramArr);
        }
        if(empty($fields))$fields = '1 = 1';
        //多表关联查询语句：
        $sql = "SELECT EES.STUDENTCODE, COUNT(EES.STUDENTCODE) AS NUM
                FROM EAS_ELC_STUDENTELCINFO EES
                WHERE $fields
                AND EES.ISPLAN = 0
                GROUP BY EES.STUDENTCODE
                ORDER BY EES.STUDENTCODE";
        $criteria=new CDbCriteria();
        //获取总记录数
        $result = $connection->createCommand("SELECT EES.STUDENTCODE FROM EAS_ELC_STUDENTELCINFO EES
                WHERE $fields
                AND EES.ISPLAN = 0
                GROUP BY EES.STUDENTCODE")->queryAll();
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

        $studentList = '';
        foreach($data as $key => $val)
        {
            ++$key == count($data) ? $studentList .= "'".$val['STUDENTCODE']."'" : $studentList .= "'".$val['STUDENTCODE']."',";
        }
        if(!empty($studentList))
        {
            //学生信息
            $studentSql = "SELECT ESS.BATCHCODE, ESS.STUDENTCODE, ESS.FULLNAME, ESS.TCPCODE, ESS.CLASSCODE,
            ESSB.GENDER, ESSB.MYPHONE, ESSB.EMAIL, EOC.CLASSNAME
            FROM EAS_SCHROLL_STUDENT ESS
            LEFT JOIN EAS_ORG_CLASSINFO EOC ON EOC.CLASSCODE = ESS.CLASSCODE
            LEFT JOIN EAS_SCHROLL_STUDENTBASICINFO ESSB ON ESSB.STUDENTCODE = ESS.STUDENTCODE
            WHERE ESS.LEARNINGCENTERCODE = '$orgCode' AND ESS.STUDENTCODE IN ($studentList)";
            $studentData = Yii::app()->db->createCommand($studentSql)->queryAll();
            foreach($studentData as $arr)
            {
                $studentData[$arr['STUDENTCODE']] = $arr;
            }
        }
        foreach($data as &$val)
        {
            $val['studentInfo'] = $studentData[$val['STUDENTCODE']];
        }
        $result['data'] = $data;
        $result['pages'] = $pages;
        $result['count'] = $pages->getItemCount();
        return $result;
    }

    /**
     * 获取选课管理学生选课信息汇总列表
     * @param array $params
     * @param int $offset
     * @param $limit
     * @param $currentPage
     * @return mixed
     */
    function getLearningCenterStudenteElcManageList(array $params, $offset=0, $limit=-1, $currentPage = -1)
    {
        //当前用户机构信息
        $user = Yii::app()->user->getState('userOrg');
        $orgCode= $user['orgCode'];
        //进行分库的学生选课表查询相关数据
        $connection = fcommon::choiceDbConnection();
        //将$_GET参数过滤，根据需要重新组成查询条件
        $paramArr = array();
        $elcBatchCode = null;
        $fields = null;
        $paramArr[] = "EES.LEARNINGCENTERCODE = '$orgCode'";
        if(!empty($params))
        {
            foreach($params as $key=>$val)
            {
                if($key == 'page' || $key == 'type' || $key == 'option')
                {
                    continue;
                }
                if(!empty($val) || ($val == 0))
                {
                    switch($key)
                    {
                        case 'dialogStudentCode':
                            $paramArr[] = "EES.STUDENTCODE like '%$val%'";
                            break;
                        default:
                            $paramArr[] = "EES.$key = $val";
                            break;
                    }
                }
            }
            $fields = implode(' and ', $paramArr);
        }
        if(empty($fields))$fields = '1 = 1';
        //多表关联查询语句：
        $sql = "SELECT EES.STUDENTCODE, COUNT(EES.STUDENTCODE) AS TOTAL, SUM(DECODE(EES.CONFIRMSTATE, 1, 1, 0)) AS CONFIRMNUM, SUM(DECODE(EES.CONFIRMSTATE, 1, 0, 1)) AS NOTCONFIRMNUM FROM EAS_ELC_STUDENTELCINFO EES
                WHERE $fields
                AND EES.ISPLAN = 0
                GROUP BY EES.STUDENTCODE
                ORDER BY EES.STUDENTCODE";
        $criteria=new CDbCriteria();
        //获取总记录数
        $result = $connection->createCommand("SELECT EES.STUDENTCODE
                FROM EAS_ELC_STUDENTELCINFO EES
                WHERE $fields
                AND EES.ISPLAN = 0
                GROUP BY EES.STUDENTCODE")->queryAll();
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

        $studentList = '';
        foreach($data as $key => $val)
        {
            ++$key == count($data) ? $studentList .= "'".$val['STUDENTCODE']."'" : $studentList .= "'".$val['STUDENTCODE']."',";
        }
        if(!empty($studentList))
        {
            $studentData = EAS_SCHROLL_STUDENT::model()->getStudentDetailInfo($orgCode, $studentList);
            foreach($studentData as $arr)
            {
                $studentData[$arr['STUDENTCODE']] = $arr;
            }
        }
        foreach($data as &$val)
        {
            $val['studentInfo'] = $studentData[$val['STUDENTCODE']];
        }
        $result['data'] = $data;
        $result['pages'] = $pages;
        $result['count'] = $pages->getItemCount();
        return $result;
    }

    /**
     * 获取某班在籍学生选择无规则选课的学生选课信息汇总列表
     * @author:pengy
     * @param array $params
     * @param int $offset
     * @param $limit
     * @param $currentPage
     * @return mixed
     */
    function getLearningCenterStudenteElcManageLists(array $params, $offset=0, $limit=-1, $currentPage = -1)
    {
        //当前用户机构信息
        $user = Yii::app()->user->getState('userOrg');
        $orgCode= $user['orgCode'];
        //进行分库的学生选课表查询相关数据
        $dbLinkName = fcommon::getDbLinkName();
        $connection = Yii::app()->db;
        //将$_GET参数过滤，根据需要重新组成查询条件
        $paramArr = array();
        $elcBatchCode = null;
        $fields = null;
        $paramArr[] = "ESS.LEARNINGCENTERCODE = '$orgCode'";
        if(!empty($params))
        {
            foreach($params as $key=>$val)
            {
                if($key == 'page' || $key == 'type' || $key == 'option')
                {
                    continue;
                }
                if(!empty($val) || ($val == 0))
                {
                    switch($key)
                    {
                        case 'BATCHCODE':
                            $batchcode = $val;
                            break;
                        case 'dialogStudentCode':
                            $paramArr[] = "ESS.STUDENTCODE like '%$val%'";
                            break;
                        default:
                            $paramArr[] = "ESS.$key = '$val'";
                            break;
                    }
                }
            }
            $fields = implode(' and ', $paramArr);
        }
        if(empty($fields))$fields = '1 = 1';
        //多表关联查询语句：
        $sql = "SELECT ESS.STUDENTCODE, ESS.FULLNAME, COUNT(EES.STUDENTCODE) AS TOTAL, SUM(DECODE(EES.CONFIRMSTATE, 1, 1, 0)) AS CONFIRMNUM,
                    SUM(DECODE(EES.CONFIRMSTATE, 0, 1, 0)) AS NOTCONFIRMNUM
                FROM EAS_SCHROLL_STUDENT ESS
                LEFT JOIN EAS_ELC_STUDENTELCINFO@$dbLinkName EES ON EES.LEARNINGCENTERCODE = ESS.LEARNINGCENTERCODE AND EES.CLASSCODE = ESS.CLASSCODE
                    AND EES.STUDENTCODE = ESS.STUDENTCODE AND EES.ISPLAN = 0 AND EES.BATCHCODE = '$batchcode'
                WHERE $fields
                AND ESS.ENROLLMENTSTATUS = 1
                GROUP BY ESS.STUDENTCODE, ESS.FULLNAME
                ORDER BY ESS.STUDENTCODE";
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

        $result['data'] = $data;
        $result['pages'] = $pages;
        $result['count'] = $pages->getItemCount();
        return $result;
    }

    /**
     * 获取学生在选课表里面未确认选课的课程信息
     * @param array $params
     * @return mixed
     */
    function getStudentNotConfirmCoursesInfo(array $params)
    {
        //当前用户机构信息
        $user = Yii::app()->user->getState('userOrg');
        $orgCode= $user['orgCode'];
        //进行分库的学生选课表查询相关数据
        $connection = fcommon::choiceDbConnection();
        //将$_GET参数过滤，根据需要重新组成查询条件
        $paramArr = array();
        if(!empty($params))
        {
            foreach($params as $key=>$val)
            {
                switch($key)
                {
                    case 'studentList':
                        $paramArr[] = "EES.STUDENTCODE IN ($val)";
                        break;
                    default:
                        $paramArr[] = "EES.$key = $val";
                        break;
                }
            }
            $fields = implode(' and ', $paramArr);
        }
        if(empty($fields))$fields = '1 = 1';
        //多表关联查询语句：
        $sql = "SELECT EES.COURSEID FROM EAS_ELC_STUDENTELCINFO EES
                WHERE EES.LEARNINGCENTERCODE = '$orgCode'
                AND $fields";
        $data = $connection->createCommand($sql)->queryAll();
        $courseIdList = '';
        $courseData = array();
        foreach($data as $key => $val)
        {
            ++$key == count($data) ? $courseIdList .= "'".$val['COURSEID']."'" : $courseIdList .= "'".$val['COURSEID']."',";
        }
        if(!empty($courseIdList))
        {
            //课程信息
            $courseSql = "SELECT * FROM EAS_COURSE_BASICINFO ECB WHERE ECB.COURSEID IN ($courseIdList)";
            $courseData = Yii::app()->db->createCommand($courseSql)->queryAll();
        }
        return $courseData;
    }



     /**
     * 获取按学生选课管理 学生未选课规则内记录，并带分页信息
     * @param array $params
     * @param int $offset
     * @param $limit
     * @param $currentPage
     * @return mixed
     */
    function getNotSelectedExec($BatchCode,$code,$orgCode,$tcpCode,$studentCode,array $params, $offset=0, $limit=-1, $currentPage = -1)
    {
        //echo '<pre>';print_r($params);die;
        //将$_GET参数过滤，根据需要重新组成查询条件
        $paramArr = array();
        $field = null;
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
                        case 'COURSEID':
                            $paramArr[] = "B.$key = $val ";
                            break;
                        case 'COURSENAME':
                            $paramArr[] = "B.$key like '%$val%' ";
                            break;
                        default:
                            continue;
                            break;
                    }
                }
            }
            $field = implode(' and ', $paramArr);
        }


        if(empty($field))$field = ' 1 = 1 ';
        //echo $BatchCode;die;
        $courseid = $this -> getCourseId($orgCode,$studentCode,$BatchCode);
		if(!empty($courseid))
		{
			$courseid = implode(',',$courseid);
			$field .= " AND A.COURSEID NOT IN($courseid) ";
		}


        //多表关联查询语句
        $sql = "SELECT A .*, B.COURSENAME,B.ORGCODE FROM( SELECT * FROM TABLE ( PK_TCP.FN_TCP_GETEXECMODULECOURSE ('".$code."','".$orgCode."','".$tcpCode."'))) A
                LEFT JOIN EAS_COURSE_BASICINFO B ON A .COURSEID = B.COURSEID
                WHERE $field
				ORDER BY A.OPENEDSEMESTER,A.COURSENATURE,A.COURSEID
                ";



        $criteria=new CDbCriteria();

        //获取总记录数
        $results = Yii::app()->db->createCommand($sql)->queryAll();



        $pages=new CPagination(count($results));
        if($currentPage != -1)
        {
            $pages->currentPage = $currentPage;
        }
        $limit == -1 ? $pages->pageSize = 2 : $pages->pageSize = $limit ;
        $pages->applyLimit($criteria);

            //
        $startNum = $pages->currentPage*$pages->pageSize;
        $endNum = $startNum + $pages->pageSize;

        $tempSql = "SELECT * FROM (SELECT tempTable.*, rownum as rownum_ FROM ($sql)tempTable WHERE rownum <= $endNum)row_ WHERE rownum_ >$startNum";

        $data = Yii::app()->db->createCommand($tempSql)->queryAll();


        $result['data'] = $data;
        $result['pages'] = $pages;
        $result['count'] = $pages->getItemCount();
        return $result;
    }

     /**
     * 获取按学生选课管理 学生未选课规则外记录，并带分页信息
     * @param array $params
     * @param int $offset
     * @param $limit
     * @param $currentPage
     * @return mixed
     */
    function getNotSelectedNoExec($BatchCode,$code,$orgCode,$tcpCode,$studentCode,array $params, $offset=0, $limit=-1, $currentPage = -1)
    {
        //echo '<pre>';print_r($params);die;
        //将$_GET参数过滤，根据需要重新组成查询条件
        $paramArr = array();
        $field = null;
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
                        case 'COURSEID':
                            $paramArr[] = "ECB.$key = $val ";
                            break;
                        case 'COURSENAME':
                            $paramArr[] = "ECB.$key like '%$val%' ";
                            break;
                        default:
                            continue;
                            break;
                    }
                }
            }
            $field = implode(' and ', $paramArr);
        }


        if(empty($field))$field = ' 1 = 1 ';
        //echo $BatchCode;die;
		//学生选课信息
        $courseid = $this -> getCourseId($orgCode,$studentCode,$BatchCode);
        $courseid = implode(',',$courseid);
        $field .= " AND ETL.BATCHCODE = $BatchCode AND ETL.ORGCODE = $code AND ETL.LEARNINGCENTERCODE = $orgCode AND ETL.ISEXISTTCP = 0 ";
		//学生执行性专业规则课程
        $field .= " AND ETL.COURSEID NOT IN(SELECT ETEM.COURSEID FROM EAS_TCP_ExecModuleCourse ETEM WHERE ETEM.BATCHCODE = $BatchCode AND ETEM.SEGMENTCODE = $code AND ETEM.LEARNINGCENTERCODE = $orgCode AND ETEM.TCPCODE = $tcpCode) ";
        $field .= " AND ETL.COURSEID NOT IN($courseid) ";

        //多表关联查询语句
        $sql = "SELECT ECB.* FROM EAS_TCP_LearCentSemeCour ETL
                LEFT JOIN EAS_COURSE_BASICINFO ECB ON ECB.COURSEID = ETL.COURSEID
                WHERE $field
                ORDER BY ETL.COURSEID";



        $criteria=new CDbCriteria();

        //获取总记录数
        $results = Yii::app()->db->createCommand($sql)->queryAll();
         //echo '<pre>';print_r($result);die;


        $pages=new CPagination(count($results));
        if($currentPage != -1)
        {
            $pages->currentPage = $currentPage;
        }
        $pages->pageSize=20;
        $pages->applyLimit($criteria);


        //分页查询数据
        $startNum = $pages->currentPage*$pages->pageSize;
        $endNum = $startNum + $pages->pageSize;

        $tempSql = "SELECT * FROM (SELECT tempTable.*, rownum as rownum_ FROM ($sql)tempTable WHERE rownum <= $endNum)row_ WHERE rownum_ >$startNum";

        $data = Yii::app()->db->createCommand($tempSql)->queryAll();


        $result['data'] = $data;
        $result['pages'] = $pages;
        $result['count'] = $pages->getItemCount();
        return $result;
    }



        //获取学生选课数据
     function getCourseId($orgCode,$studentCode,$BatchCode)
    {
         //如果传递过来是第一次选课
         if($num == '1')
         {
            $CURRENTSELECTNUMBER = " AND CURRENTSELECTNUMBER =1";
         }
         //echo $CURRENTSELECTNUMBER;die;
         //进行分库的学生选课表查询相关数据
         $connection = fcommon::choiceDbConnection();


         $sql = "SELECT EES.COURSEID
                       FROM EAS_ELC_STUDENTELCINFO EES
                       WHERE EES.LEARNINGCENTERCODE = '$orgCode'
                       AND EES.STUDENTCODE = '$studentCode'
                       AND EES.BATCHCODE = '$BatchCode'

                       ";

        $data = $connection->createCommand($sql)->queryColumn();
        return $data;

    }


        //获取学生规则内首次选课数据
     function getFirstisPlanCourse($orgCode,$studentCode,$BatchCode)
    {
         //进行分库的学生选课表查询相关数据
         $connection = fcommon::choiceDbConnection();
         $isPlanSql = "SELECT EES.*
                       FROM EAS_ELC_STUDENTELCINFO EES
                       WHERE EES.LEARNINGCENTERCODE = '$orgCode'
                       AND EES.STUDENTCODE = '$studentCode'
                       AND EES.BATCHCODE = '$BatchCode'
                       AND EES.ISPLAN = 1
                       AND EES.CURRENTSELECTNUMBER = 1
                       ";
        $data = $connection->createCommand($isPlanSql)->queryAll();
        return $data;
    }



     /**
     * 按班获取未确定选课课程信息表
     * @param array $params
     * @param int $offset
     * @param $limit
     * @param $currentPage
     * @return mixed
     */
    function getLearningCenterNotConfirmCoursesList(array $params, $offset=0, $limit=-1, $currentPage = -1)
    {
        //当前用户机构信息
        $user = Yii::app()->user->getState('userOrg');
        $orgCode= $user['orgCode'];
        //进行分库的学生选课表查询相关数据
        $connection = fcommon::choiceDbConnection();
        //将$_GET参数过滤，根据需要重新组成查询条件
        $paramArr = array();
        $elcBatchCode = null;
        $fields = null;
        if(!empty($params))
        {
            foreach($params as $key=>$val)
            {
                if($key == 'page' || $key == 'type' || $key == 'option')
                {
                    continue;
                }
                if(!empty($val) || ($val == 0))
                {
                    switch($key)
                    {

                        case 'CONFIRMSTATE':
                            empty($val) ? $paramArr[] = "nvl(EES.CONFIRMSTATE,'0')<>'1'" :  $paramArr[] = "EES.$key = $val";
                            break;
                        default:
                            $paramArr[] = "EES.$key = $val";
                            break;
                    }
                }
            }
            $fields = implode(' and ', $paramArr);
        }
        if(empty($fields))$fields = '1 = 1';
        //多表关联查询语句：
        $sql = "SELECT * FROM EAS_ELC_STUDENTELCINFO EES
                WHERE EES.LEARNINGCENTERCODE = '$orgCode'
                AND $fields

                ORDER BY EES.STUDENTCODE, EES.COURSEID";
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

        $courseIdList = '';
        $studentList = '';
        foreach($data as $key => $val)
        {
            if(++$key == count($data))
            {
                $courseIdList .= "'".$val['COURSEID']."'";
                $studentList .= "'".$val['STUDENTCODE']."'";
            }
            else
            {
                $courseIdList .= "'".$val['COURSEID']."',";
                $studentList .= "'".$val['STUDENTCODE']."',";
            }
        }
        if(!empty($courseIdList))
        {
            //课程信息
            $courseSql = "SELECT ECB.COURSEID,ECB.COURSENAME FROM EAS_COURSE_BASICINFO ECB WHERE ECB.COURSEID IN ($courseIdList)";
            $temp_courseData = Yii::app()->db->createCommand($courseSql)->queryAll();
            $courseData = array();
            foreach($temp_courseData as $arr)
            {
                $courseData[$arr['COURSEID']] = $arr;
            }
        }
        if(!empty($studentList))
        {
            //学生信息
            $studentSql = "SELECT ESSB.STUDENTCODE, ESS.FULLNAME ,ESSB.GENDER,ESSB.MOBILE,ESSB.EMAIL FROM EAS_SCHROLL_STUDENT ESS
                           LEFT JOIN EAS_SchRoll_StudentBasicInfo ESSB ON ESS.STUDENTCODE = ESSB.STUDENTCODE
                            WHERE ESS.STUDENTCODE IN ($studentList)";


            $temp_studentData = Yii::app()->db->createCommand($studentSql)->queryAll();

            $studentData = array();
            foreach($temp_studentData as $arr)
            {
                $studentData[$arr['STUDENTCODE']] = $arr;
            }

        }
        foreach($data as &$val)
        {
            $val['courseDetail'] = $courseData[$val['COURSEID']];
            $val['STUDENTNAME'] = $studentData[$val['STUDENTCODE']];
        }
        $result['data'] = $data;
        $result['pages'] = $pages;
        $result['count'] = $pages->getItemCount();

        return $result;
    }

    /**
     * 获取学习中心选课详细信息表
     * @param array $params
     * @param int $offset
     * @param $limit
     * @param $currentPage
     * @return mixed
     */
    function getLearningCenterElectivesDetailInfoList(array $params, $offset=0, $limit=-1, $currentPage = -1)
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
                        case 'elcBatchCode':
                            $paramArr[] = "SEI.BATCHCODE = '$val'";
                            break;
                        case 'currentOrg':
                            if($val != '010')
                            {
                                $paramArr[] = "SEI.LEARNINGCENTERCODE LIKE '$val%'";
                            }
                            break;
                        case 'CourseId':
                            $paramArr[] = "SEI.$key LIKE '%$val%'";
                            break;
                        case 'LearningCenter':
                            $paramArr[] = "SEI.LEARNINGCENTERCODE = '$val'";
                            break;
                        case 'College':
                            $paramArr[] = "SEI.LEARNINGCENTERCODE LIKE '$val%'";
                            break;
                        case 'Segment':
                            $paramArr[] = "SEI.LEARNINGCENTERCODE LIKE '$val%'";
                            break;
                        case 'StudentCode':
                        case 'FullName':
                            $paramArr[] = "ESS.$key LIKE '%$val%'";
                            break;
                        case 'ClassCode':
                        case 'ClassName':
                            $paramArr[] = "EOC.$key LIKE '%$val%'";
                            break;
                        case 'ConfirmState':
                            empty($val) ? $paramArr[] = "nvl(SEI.CONFIRMSTATE,'0')<>'1'" :  $paramArr[] = "SEI.$key = $val";
                            break;
                        default:
                            $paramArr[] = "ESS.$key = '$val'";
                            break;
                    }
                }
            }
            $fields = implode(' and ', $paramArr);
        }
        if(empty($fields))$fields = '1 = 1';
        //选课记录查询
        $sql = "SELECT * FROM(
                SELECT SEI.*,ESS.TCPCODE,ESS.FULLNAME,EOC.CLASSNAME,SEG.ORGANIZATIONNAME AS SEGMENTNAME,COL.ORGANIZATIONNAME AS COLLEGENAME,LEA.ORGANIZATIONNAME AS LEARNINGCENTERNAME
                FROM EAS_ELC_STUDENTELCINFO@ouchn112 SEI
                LEFT JOIN EAS_SCHROLL_STUDENT ESS ON ESS.STUDENTCODE = SEI.STUDENTCODE
                LEFT JOIN EAS_ORG_CLASSINFO EOC ON EOC.CLASSCODE = SEI.CLASSCODE
                LEFT JOIN EAS_ORG_BASICINFO SEG ON SEG.ORGANIZATIONCODE = SUBSTR(ESS.LEARNINGCENTERCODE,1,3)
                LEFT JOIN EAS_ORG_BASICINFO COL ON COL.ORGANIZATIONCODE = SUBSTR(ESS.LEARNINGCENTERCODE,1,5)
                LEFT JOIN EAS_ORG_BASICINFO LEA ON LEA.ORGANIZATIONCODE = ESS.LEARNINGCENTERCODE
                WHERE $fields
                UNION ALL
                SELECT SEI.*,ESS.TCPCODE,ESS.FULLNAME,EOC.CLASSNAME,SEG.ORGANIZATIONNAME AS SEGMENTNAME,COL.ORGANIZATIONNAME AS COLLEGENAME,LEA.ORGANIZATIONNAME AS LEARNINGCENTERNAME
                FROM EAS_ELC_STUDENTELCINFO@ouchn113 SEI
                LEFT JOIN EAS_SCHROLL_STUDENT ESS ON ESS.STUDENTCODE = SEI.STUDENTCODE
                LEFT JOIN EAS_ORG_CLASSINFO EOC ON EOC.CLASSCODE = SEI.CLASSCODE
                LEFT JOIN EAS_ORG_BASICINFO SEG ON SEG.ORGANIZATIONCODE = SUBSTR(ESS.LEARNINGCENTERCODE,1,3)
                LEFT JOIN EAS_ORG_BASICINFO COL ON COL.ORGANIZATIONCODE = SUBSTR(ESS.LEARNINGCENTERCODE,1,5)
                LEFT JOIN EAS_ORG_BASICINFO LEA ON LEA.ORGANIZATIONCODE = ESS.LEARNINGCENTERCODE
                WHERE $fields)
                ORDER BY LEARNINGCENTERCODE, CLASSCODE";
        $criteria=new CDbCriteria();
        //获取总记录数
        $result = Yii::app()->db->createCommand($sql)->queryAll();
        $pages=new CPagination(count($result));
        if($currentPage != -1)
        {
            $pages->currentPage = $currentPage;
        }
        $limit == -1 ? $pages->pageSize = 20 : $pages->pageSize = $limit ;
        $pages->applyLimit($criteria);

        //分页查询数据
        if(isset($_GET['exportFlag']) && $_GET['exportFlag'] == '1')
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

        foreach($data as $key => &$val)
        {
            $learningCenterCode = $val['LEARNINGCENTERCODE'];
            $courseid = $val['COURSEID'];
            $tcpcode = $val['TCPCODE'];
            //课程信息
            $courseSql = "SELECT AC.* ,ECB.COURSENAME FROM EAS_COURSE_BASICINFO ECB
                              LEFT JOIN (SELECT * FROM TABLE (PK_TCP.FN_TCP_GETEXECMODULECOURSE ('substr(trim($learningCenterCode), 0, 3)', '$learningCenterCode','$tcpcode'))
                                    UNION
                                    SELECT A.* FROM TABLE (PK_TCP.FN_TCP_GETEXECMODULECOURSE ('substr(trim($learningCenterCode), 0, 3)', '$learningCenterCode','$tcpcode')) A
                                    LEFT JOIN EAS_COURSE_MUTEXCOURSES B ON A.COURSEID = B.Oldcoursecode
                                    WHERE A.COURSESTATE = 0 AND A.COURSENATURE IN (1, 2)) AC ON AC.COURSEID = ECB.COURSEID
                               WHERE ECB.COURSEID = $courseid";
            $temp_courseData = Yii::app()->db->createCommand($courseSql)->queryRow();
            $val['courseDetail'] = $temp_courseData;
        }
        $result['data'] = $data;
        $result['pages'] = $pages;
        $result['count'] = $pages->getItemCount();
        return $result;
    }
}
