<?php

/*
 * @author jiakd@mail.open.cn
 * @license 
 * 数据存储类
 */
class kvstore extends CApplicationComponent{

    /*
     * @var string $__instance
     * @access static private
     */
    static private $__instance = array();

    /*
     * @var string $__persistent
     * @access static private
     */
    static private $__persistent = false;

    /*
     * @var string $__controller
     * @access private
     */
    private $__controller = null;

    /*
     * @var string $__prefix
     * @access private
     */
    private $__prefix = null;
    
    /*
     * @var string $__fetch_count
     * @access static public
     */
    static public $__fetch_count = 0;

    /*
     * @var string $__store_count
     * @access static public
     */
    static public $__store_count = 0;

    /*
     * 构造
     * @var string $prefix
     * @access public
     * @return void
     */
    function __construct($prefix){

		$con = new kvstore_filesystem($prefix);
		$this->set_controller($con);
        $this->set_prefix($prefix);
    }//End Function

    /*
     * 设置持久化与否
     * @var boolean $flag
     * @access public
     * @return string
     */
    static function config_persistent($flag) 
    {
        self::$__persistent = ($flag) ? true : false;
    }//End Function

    /*
     * 返回KV_PREFIX
     * @access public
     * @return string
     */
    static public function kvprefix() 
    {
      
        return (defined('KV_PREFIX')) ? KV_PREFIX : 'defalut'; 
    }//End Function

    /*
     * 实例一个kvstore
     * @var string $prefix
     * @access public
     * @return object
     */

    static public function instance($prefix){
        if(!isset(self::$__instance[$prefix])){
		    self::$__instance[$prefix] = new kvstore($prefix);
        }
        return self::$__instance[$prefix];
    }//End Function

    /*
     * 设置prefix
     * @var string $prefix
     * @access public
     * @return void
     */
    public function set_prefix($prefix) 
    {
        $this->__prefix = $prefix;
    }//End Function

    /*
     * 取得prefix
     * @access public
     * @return string
     */
    public function get_prefix() 
    {
        return $this->__prefix;
    }//End Function

    /*
     * 设置kvstore控制器
     * @var object $controller
     * @access public
     * @return void
     */
    public function set_controller($controller) 
    {
        if($controller instanceof kvstore_base){
            $this->__controller = $controller;
		}
      
    }//End Function

    /*
     * 得到kvstore控制器
     * @access public
     * @return object
     */
    public function get_controller() 
    {
        return $this->__controller;
    }//End Function


    /*
     * 获取key的内容
     * @var string $key
     * @var mixed &$value
     * @var int $timeout_version
     * @access public
     * @return boolean
     */
    public function fetch($key, &$value, $timeout_version=null){
        self::$__fetch_count++;
        if($this->get_controller()->fetch($key, $value, $timeout_version)){
            return true;
        }else{
            return false;
        }
    }//End Function

    /*
     * 设置key的内容
     * @var string $key
     * @var mixed $value
     * @var int $ttl
     * @access public
     * @return boolean
     */
    public function store($key, $value, $ttl=0)
    {
        self::$__store_count++;
      
        return $this->get_controller()->store($key, $value, $ttl);
    }//End Function

    /*
     * 删除key的内容
     * @var string $key
     * @var int $ttl
     * @access public
     * @return boolean
     */
    public function delete($key, $ttl=1) 
    {
        if($this->fetch($key, $value)){
            return $this->store($key, $value, ($ttl>0)?$ttl:1);    
        }
        return true;
    }//End Function

    /*
     * 数据持久化
     * @var string $key
     * @var mixed $value
     * @var int $ttl
     * @access public
     * @return void
     */
    public function persistent($key, $value, $ttl=0) 
    {
       
    }//End Function
    
    /*
     * 数据还原
     * @var array $record
     * @access public
     * @return boolean
     */
    public function recovery($record) 
    {
        
    }//End Function

    /*
     * 删除过期数据
     * @var array $record
     * @access public
     * @return boolean
     */
    static public function delete_expire_data() 
    {
        
    }//End Function

}//End Class
