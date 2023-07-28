# terraform-template

次の構成を作成する Terraform です

![network img](image/network.jpg)

- 主に NAT と Aurora に費用がかかります
- Aurora が不要な場合は`main.tf`で`Database`のブロックをコメントアウトしてください

## 使い方

初期化

```
$ terraform init
```

実行計画の表示

```
$ terraform plan
```

実行

```
$ terraform apply
```

削除

```
$ terraform destroy
```

## 踏み台サーバへの接続方法
