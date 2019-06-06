class ChengYu {
  static const int ACCEPTABLE_QUALITY = 3;
  static const double DEFAULT_EASINESS = 2.5;
  static const int DEFAULT_LEARNING_INTERVAL = 600; // 10 minutes (in seconds)
  static const int DEFAULT_LEARNED_INTERVAL = 345600; // 4 days (in seconds)
  static const int GRADUATION_STEP = 5;

  static const NEW_STAGE = 0;
  static const LEARNING_STAGE = 1;
  static const LEARNED_STAGE = 2;
  static const HIDDEN_STAGE = 3;

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

  int correctGuesses = 0;
  int incorrectGuesses = 0;

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
    return stage == LEARNED_STAGE;
  }

  bool isLearning() {
    return stage == LEARNING_STAGE;
  }

  bool isHidden() {
    return stage == HIDDEN_STAGE;
  }

  bool isNew() {
    return stage == NEW_STAGE || stage == null;
  }

  void recordGuess(bool correct) {
    if(correct) {
      correctGuesses++;
    } else {
      incorrectGuesses++;
    }
  }

  /// Process guesses and calculate next SRS state.
  /// This algorithm is adopted from Piotr Wozniak's SuperMemo-2 and that
  /// outlined in the Anki manual. Similar to the Anki algorithm,
  /// repetition intervals differ across 'learning' chengyu and 'learned' chengyu.
  /// Namely, 'learning' chengyu must be seen and guessed correctly LEARNING_STEPS
  /// times (particularly, must occur in LEARNING_STEPS completed games) in order
  /// to be considered 'learned'. Also common to the Anki algorithm, the easiness
  /// factor of chengyu in the 'learning' phase does not decrease - chengyu the
  /// user keeps getting wrong while still learning will not incessantly reappear
  /// after they finally progress to the 'learned' stage. A description of the
  /// algorithm divided by chengyu stage follows.
  ///
  /// QUALITY = MAX(0, TOP_QUALITY - incorrectGuesses)
  ///
  /// NEW
  /// 1. Graduate to 'learning' with easiness calculated accordingly.
  ///
  /// LEARNING
  /// 1. If quality < ACCEPTABLE_QUALITY, reset 'steps' to 0
  /// 2. If quality >= ACCEPTABLE_QUALITY:
  ///       1. Adjust easiness
  ///       2. If 'steps' < GRADUATION_STEP, increase 'steps' by 1
  ///          Otherwise, graduate to LEARNED_STATE and reset 'steps' to 0
  ///
  /// LEARNED
  /// 1. If quality < ACCEPTABLE_QUALITY, set state to LEARNING_STATE and
  ///    reset easiness to DEFAULT_EASINESS
  /// 2. If quality >= ACCEPTABLE_QUALITY:
  ///       1. Adjust easiness
  ///       2. Increment steps (bookkeeping only)
  ///       3. Set new_interval_length = (timeDue - timeStaged) * easiness
  void processSRS() {
    int quality = 5 - incorrectGuesses;
    if (quality < 0) {
      quality = 0;
    }

    double newEasiness = easiness;
    if(isLearned()) {
      newEasiness = easiness + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
      if (newEasiness < 1.3) {
        newEasiness = 1.3;
      }
    }

    if(stage == NEW_STAGE) {
      if(quality >= ACCEPTABLE_QUALITY) {
        easiness = newEasiness;
      }
      stage = LEARNING_STAGE;
      steps = 0;

      /// LEARNING_STAGE should ignore timeStaged and timeDue
      //timeStaged = 0; // TODO: datetime.now()
      //timeDue = timeStaged + DEFAULT_LEARNING_INTERVAL;
    } else if (stage == LEARNING_STAGE) {
      if(quality >= ACCEPTABLE_QUALITY) {
        easiness = newEasiness;
        steps++;
        if (steps >= GRADUATION_STEP) {
          stage = LEARNED_STAGE;
          steps = 0;
          timeStaged = 0; // TODO: datetime.now()
          timeDue = timeStaged + DEFAULT_LEARNED_INTERVAL;
        }
      } else {
        steps = 0;
      }
    } else if (stage == LEARNED_STAGE) {
      if(quality >= ACCEPTABLE_QUALITY) {
        easiness = newEasiness;
        steps++; // bookkeeping only
        var now = 0; // TODO: datetime.now()
        timeDue = now + ((timeDue - timeStaged) * easiness).toInt();
        timeStaged = now;
      } else {
        stage = LEARNING_STAGE;
        steps = 0;
      }
    } else {
      print("WARNING!!! GHOST STAGE!!!");
    }
  }

  void _resetToLearning() {

  }
}