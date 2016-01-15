<?php


interface kvstore_base{

    function store($key, $value, $ttl=0);

    function fetch($key, &$value, $timeout_version=null);

    function delete($key);

    function recovery($record);
}
