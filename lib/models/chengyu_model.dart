class ChengYu {
  int id;
  String chengYu;
  String zhuYin;
  String pinYin;
  String shiYi;
  String dianYuan;
  String dianGuShuoMing;
  String shuZheng;
  String yongFaShuoMing;
  String jinYi;
  String bianShi;
  String canKaoYuCi;

  int timeStaged;
  int timeDue;
  int steps;
  double easiness;
  int stage;

  void loadEntryFromSQLRow(Map<String, dynamic> row) {
    id = row['id'];
    chengYu = row['chengyu'];
    zhuYin = row['zhuyin'];
    pinYin = row['pinyin'];
    shiYi = row['shiyi'];
    dianYuan = row['dianyuan'];
    dianGuShuoMing = row['diangushuoming'];
    shuZheng = row['shuzheng'];
    yongFaShuoMing = row['yongfashuoming'];
    jinYi = row['jinyi'];
    bianShi = row['bianshi'];
    canKaoYuCi = row['cankaoyuci'];
  }

  void loadStatsFromSQLRow(Map<String, dynamic> row) {
    timeStaged = row['timeStaged'];
    timeDue = row['timeDue'];
    steps = row['steps'];
    easiness = row['easiness'];
    stage = row['stage'];
  }

  bool isLearned() {
    return stage == 2;
  }

  bool isLearning() {
    return stage == 1;
  }

  bool isHidden() {
    return stage == 0;
  }

  bool isNew() {
    return !(isLearned() || isLearning() || isHidden());
  }
}