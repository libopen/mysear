<?php

/**
 * This is the model class for table "EAS_ELC_STUDENTSTUDYSTATUS".
 *
 * The followings are the available columns in table 'EAS_ELC_STUDENTSTUDYSTATUS':
 * @property integer $SN
 * @property string $STUDENTCODE
 * @property string $COURSEID
 * @property string $STUDYSTATUS
 * @property integer $SIGNUPNUM
 * @property double $SCORE
 * @property string $SCORECODE
 * @property string $SCORETYPE
 */
class EAS_ELC_STUDENTSTUDYSTATUS extends CActiveRecord
{
         public static $server_name = 'db';
         public static $master_db;
	/**
	 * @return string the associated database table name
	 */
	public function tableName()
	{
		return 'EAS_ELC_STUDENTSTUDYSTATUS';
	}

	/**
	 * @return array validation rules for model attributes.
	 */
	public function rules()
	{
		// NOTE: you should only define rules for those attributes that
		// will receive user inputs.
		return array(
			array('SIGNUPNUM', 'numerical', 'integerOnly'=>true),
			array('SCORE', 'numerical'),
			array('STUDENTCODE', 'length', 'max'=>20),
			array('COURSEID, SCORECODE', 'length', 'max'=>10),
			array('STUDYSTATUS, SCORETYPE', 'length', 'max'=>2),
			// The following rule is used by search().
			// @todo Please remove those attributes that should not be searched.
			array('SN, STUDENTCODE, COURSEID, STUDYSTATUS, SIGNUPNUM, SCORE, SCORECODE, SCORETYPE', 'safe', 'on'=>'search'),
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
			'STUDENTCODE' => '学号',
			'COURSEID' => '课程编号',
			'STUDYSTATUS' => '选课状态
0:未选课
1:已选课
2:学习中
3:未通过
4:已修完
',
			'SIGNUPNUM' => 'Signupnum',
			'SCORE' => 'Score',
			'SCORECODE' => 'Scorecode',
			'SCORETYPE' => 'Scoretype',
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
		$criteria->compare('STUDENTCODE',$this->STUDENTCODE,true);
		$criteria->compare('COURSEID',$this->COURSEID,true);
		$criteria->compare('STUDYSTATUS',$this->STUDYSTATUS,true);
		$criteria->compare('SIGNUPNUM',$this->SIGNUPNUM);
		$criteria->compare('SCORE',$this->SCORE);
		$criteria->compare('SCORECODE',$this->SCORECODE,true);
		$criteria->compare('SCORETYPE',$this->SCORETYPE,true);

		return new CActiveDataProvider($this, array(
			'criteria'=>$criteria,
		));
	}

	/**
	 * @return CDbConnection the database connection used for this class
	 */
	public function getDbConnection()
	{
	//	return Yii::app()->db112;
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
	 * @return EAS_ELC_STUDENTSTUDYSTATUS the static model class
	 */
	public static function model($className=__CLASS__)
	{
		return parent::model($className);
	}
}
