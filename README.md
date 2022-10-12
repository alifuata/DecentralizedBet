# DecentralizedBet
Decentralized Bet Application

SportsBet isimli contract merkezi olmayan iddia uygulamasıdır. Uygulama deploy edilirken uygulamaya ait ana hesap tanımlanır ve para gönderme, sisteme iddia girme, maç sonuçlarını girerek kazananların tutarlarını gönderme işlemi bu hesap tarafından yapılmaktadır.

Contract üzerinde Game struct; oyuna ait bilgileri tutmak için oluşturulmuştur. Takımların bilgileri, maçın başlama ve bitiş zamanı, oyuna ait id ve sonucunu tutacak GameResult isminde enum değişkenini barındırır.

Player isimli struct ile de maça bahis koyan kişilere ait adres, GameResult enum türünde sonuç, yatırılan tutar, kazanıp kazanmadığına dair değişken, ve kazandığı tutar değişkenini tutar.

hesaba bahis için gelen tüm değerler balance isimli değişkende tutularak sonuçlarına göre kazananlara bedelleri buradan dağıtılır.

Bahis yapılabilecek tüm maçlara ait bilgiler Game dizisi türünde games değişkeninde saklanır. Sahip hesabın girdiği veriler buraya yazılır ve arayüzde kullanıcılara gösterilecek olan maçlar buradan çekilir.

Uygulamaya ait GameAdded, GameEnded, TranactionsCompleted ve PlayerJoinBet isimli eventlar sırasıyla maç eklenmesi, maçın sonlanması, kazananlara bedellerinin aktarılması ve kullanıcıların katılımları durumlarında tetiklenir.

Yapıcı fonksiyon ile contract sahiplik adresi ve %10 olacak şekilde işlem gideri oranı belirlenir

AddGame methodu başlamamış maçları kontrol ederek sisteme kaydeder, GetMatches metodu ile bu kayıt edilen maçların bilgisi alınabilir. 

JoinBet ile kullanıcıların bir maça bahis yatırması sağlanır, kullanıcılardan maça ait Id tutar, tercihleri ve adresleri gibi bilgileri istenir.
 EndGame methodu ile bir maça ait sonuç girilir. maçın sonucu ile birlikte kaybeden iddialara ait tutarlardan %10 luk bir kesinti yapılır, kalan tutar, kazananların yatırdıkları tutarın genel toplamından kullanıcının tutarına göre tespit edilen oran ile hesaplanarak kendi yatırdığı para ile birlikte ödenir.
 
 Maçlara hangi kullanıcıların katıldığı bilgisi Bets isimli mapping ile tutulur. Key değeri maça ait eşsiz ID ve o maça ait bahis oynayan kullanıcıları barındırır.

FindGame ve stringEquals methodları contract içi arama işlemleri için geliştirilmiştir.
