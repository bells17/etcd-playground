etcdctl --endpoints=$ETCD_ENDPOINTS txn <<<'value("user1") = "bad"

del user1

put user1 good

'
