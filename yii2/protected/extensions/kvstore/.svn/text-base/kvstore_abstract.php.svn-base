<?php

abstract class kvstore_abstract 
{
    
    /*
     * 生成经过处理的唯一key
     * @var string $key
     * @access public
     * @return string
     */
    public function create_key($key) 
    {
        return md5(kvstore::kvprefix() . $this->prefix . $key);
    }//End Function

}//End Class