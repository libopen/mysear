<?php

class Ccsv extends CApplicationComponent {
    public $delimiter = ',';
    public $enclosure = '"';
    public $length = 99999;

    /**
     * generation
     * 生成CSV文件行内容
     * @param  array $csv_data       csv数据一维数组
     * @author wangkang
     * @since 2014-3-3 
     * @return string
     */
    public function generation($csv_data){
        $separater = sprintf('%s%s%s', $this->enclosure, $this->delimiter, $this->enclosure);// ","

        return sprintf('%s%s%s',  $this->enclosure, implode($separater, $csv_data), $this->enclosure);// "%s"
    }

    /**
     * format
     * 输出回车换行符
     * @author wangkang
     * @since 2012-2-2 15:57:48
     * @return string
     */
    public function format(){
        return "\n";
    }

    /**
     * 设置发送CSV文件头
     *
     * @param       string       $csv_file_name       csv文件名
     * @return      boolen
     */
    public function set_header($csv_file_name){
        header("Content-Type: text/csv");
        header("Content-Disposition: attachment; filename=" . $csv_file_name);
        header('Cache-Control:must-revalidate,post-check=0,pre-check=0');
        header('Expires: 0');
        header('Pragma: public');

        return true;
    }

   /**
    * fgetcsv
    * csv文件转码
    */
    public function fgetcsv(& $handle, $length = null, $d = ',', $e = '"') {
         $d = preg_quote($d);
         $e = preg_quote($e);
         $_line = "";
         $eof=false;
         while ($eof != true) {
             $_line .= (empty ($length) ? fgets($handle) : fgets($handle, $length));
             $itemcnt = preg_match_all('/' . $e . '/', $_line, $dummy);
             if ($itemcnt % 2 == 0)
                 $eof = true;
         }
         $_csv_line = preg_replace('/(?: |[ ])?$/', $d, trim($_line));
         $_csv_pattern = '/(' . $e . '[^' . $e . ']*(?:' . $e . $e . '[^' . $e . ']*)*' . $e . '|[^' . $d . ']*)' . $d . '/';
         preg_match_all($_csv_pattern, $_csv_line, $_csv_matches);
         $_csv_data = $_csv_matches[1];
         for ($_csv_i = 0; $_csv_i < count($_csv_data); $_csv_i++) {
             $_csv_data[$_csv_i] = preg_replace('/^' . $e . '(.*)' . $e . '$/s', '$1' , $_csv_data[$_csv_i]);
             $_csv_data[$_csv_i] = str_replace($e . $e, $e, $_csv_data[$_csv_i]);
         }
         return empty ($_line) ? false : $_csv_data;
    }

    public function updatetolocal($csv_data){
	
	    $data = array();
	    foreach($csv_data as &$val){
            $data[] = iconv('utf-8','gbk', $val);
		}
		return $data;
    }

}
?>
