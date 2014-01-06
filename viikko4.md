# Beta-versio, lukeminen omalla vastuulla!

Jatkamme sovelluksen rakentamista siitä mihin jäimme viikon 3 lopussa. Allaoleva materiaali olettaa, että olet tehnyt kaikki edellisen viikon tehtävät. Jos et tehnyt kaikkia tehtäviä, voit ottaa kurssin repositorioista edellisen viikon mallivastauksen (ilmestyy 23.9. klo 00:01). Jos sait suurimman osan edellisen viikon tehtävistä tehtyä helpointa saattaa olla että täydennät vastaustasi mallivastauksen avulla.

Jos otat edellisen viikon mallivastauksen tämän viikon pohjaksi, kopioi hakemisto pois kurssirepositorion alta (olettaen että olet kloonannut sen) ja tee sovelluksen sisältämästä hakemistosta uusi repositorio.

## Testaus

Toistaiseksi olemme tehneet koodia, jonka toimintaa olemme testanneet ainoastaan selaimesta. Tämä on suuri virhe. Jokaisen eliniältään laajemmaksi tarkoitetun ohjelman on syytä sisältää kattavat automaattiset testit, muuten ajan mittaan käy niin että ohjelman laajentaminen tulee liian riskialttiiksi.

Käytämme testaukseen Rspec:iä ks. http://rspec.info/,  https://github.com/rspec/rspec-rails ja
http://betterspecs.org/

Otetaan käyttöön rspec-rails gem lisäämällä Gemfileen seuraava:

```ruby
group :development, :test do
  gem 'rspec-rails', '~> 2.0'
end
```

Uusi gem otetaan käyttöön tutulla tavalla, eli antamalla komentoriviltä komento <code>bundle install</code>

rspec saadaan initialisoitua sovelluksen käyttöön atamalla komentoriviltä komento

    rails generate rspec:install

Initialisointi luo sovellukselle hakemiston /spec jonka alihakemistoihin testit eli "spekit" sijoitetaan.

Railsin oletusarvoinen, mutta nykyään vähemmän käytetty testausframework sijoittaa testit hakemistoon /test. Ko. hakemisto on tarpeeton rspecin käyttöönoton jälkeen ja se voidaan poistaa.

Testejä (oikeastaan rspecin yhteydessä ei pitäisi puhua testeistä vaan spekeistä tai spesifikaatioista, käytämme kuitenkin jatkossa sanaa testi) voidaan kirjoittaa usealle tasolle: yksikkötestejä luokille, näkymätestejä, integraatiotestejä kontrollereille tai http-pyyntöjen tasolla toimivia koko sovellusta testaavia testejä. Näiden lisäksi sovellusta voidaan testata käyttäen simuloitua selainta capybara-gemin  https://github.com/jnicklas/capybara avulla.

Kirjoitamme jatkossa lähinnä yksikkötestejä ja capybaran avulla simuloituja selaintason testejä.

## Yksikkötestit

Tehdään kokeeksi muutama yksikkötesti luokalle <code>User</code>. Voimme luoda testipohjan käsin tai rspec-generaattorilla

    rails generate rspec:model user

Hakemistoon /spec/model tulee tiedosto user_spec.rb

```ruby
require 'spec_helper'

describe User do
  pending "add some examples to (or delete) #{__FILE__}"
end
```

Kokeillaan ajaa testit komentoriviltä komennolla <code>rspec spec</code>:

```ruby
mluukkai@e42-17:~/WadRoR/ratebeer$ rspec spec
*

Pending:
  User add some examples to (or delete) /home/mluukkai/WadRoR/ratebeer/spec/models/user_spec.rb
    # No reason given
    # ./spec/models/user_spec.rb:4

Finished in 0.00945 seconds
1 example, 0 failures, 1 pending

Randomized with seed 32559
```

Komento määrittelee, että suoritetaan kaikki testit jotka löytyvät hakemiston spec alihakemistoista. Jos testejä on paljon, on myös mahdollista ajaa suppeampi joukko testejä:

    rspec spec/model                # suoritetaan hakemiston model sisältävät testit
    rspec spec/model/user_spec.rb   # suoritetaan user_spec.rb:n määrittelemät testi

rspec-rails luo myös rake-taskit testien ajoon ja asettaa ```rake spec```-taskin oletukseksi. Voit listata kaikki testeihin liittyvät taskit komennolla ```rake -T spec```.

Testien ajon voi myös automatisoida aina kun testi tai sitä koskeva koodi muuttuu. [guard](https://github.com/guard/guard) on tähän käytetty kirjasto ja siihen löytyy monia laajennoksia.

Kirjoitetaan nyt testi joka testaa, että konstruktori asettaa käyttäjätunnuksen oikein.

```ruby
describe User do
  it "has the username set correctly" do
    user = User.new :username => "Pekka"

    user.username.should == "Pekka"
  end
end
```

Testi kirjoitetaan <code>it</code>-nimiselle metodille annettavan koodilohkon sisään. Metodin ensimmäisenä parametrina on merkkijono joka toimii testin nimenä. Muuten testi kirjoitetaan "xUnit-tyyliin", eli ensin luodaan testattava data sitten suoritetaan testattava toimenpide ja lopuksi varmistetaan että vastaus on odotettu.

Ajettaessa testi tulee virheilmoitus. Huomaamme että syy on seuraava:

```ruby
     Failure/Error: user = User.new :username => "Pekka"
     ActiveRecord::StatementInvalid:
       Could not find table 'users'
```

Eli tietokantataulua <code>users</code> ei ole olemassa. Syynä on se, että Rails ajaa testit eri ympäristössä kuin missä sovelluskehitys tapahtuu. Sovelluskehitysympäristössä (development) ja testiympäristössä on mm. molemmissa oma tietokanta, ja tietokantamigraatioita ei ole testiympäristössä vielä suoritettu. Asia hoituu komennolla:

    rake db:test:prepare

Nyt testi toimii.

Toisin kuin xUnit-perheen testauskehyksissä, Rspecin yhteydessä ei käytetä assert-komentoja testin odotetun tuloksen määrittelemiseen. Käytössä on hieman erikoisemman näköinen syntaksi kuten testin viimeisellä rivillä oleva:

    user.username.should == "Pekka"

Rspec lisää jokaiselle luokalle metodin <code>should</code>, jonka avulla voidaan määritellä testin odotettu käyttäytyminen siten, että määrittely olisi luettavuudeltaan mahdollisimman luonnollisen kielen ilmaisun kaltainen.

Kuten aina rubyssä, on myös Rspecissä useita vaihtoehtoisia tapoja tehdä sama asia. Metodin should sijaan edellinen voitaisiin kirjoittaa myös hieman modernimman rspec-tyylin mukaisesti:

    expect(user.username).to eq("Pekka")

Käytämme jatkossa sekaisin molempia tyylejä, expectiä ja shouldia.

Äskeisessä testissä käytettiin komentoa <code>new</code>, joten olioa ei talletettu kantaan. Kokeillaan nyt olion tallettamista. Olemme määritelleet, että User-olioilla tulee olla salasana, jonka pituus on vähintään 4. Eli jos salasanaa ei aseteta, ei oliota tulisi tallettaa tietokantaan. Testataan että näin tapahtuu:

```ruby
describe User do
  it "is not saved without a proper password" do
    user = User.create :username => "Pekka"

    expect(user.valid?).to be(false)
    expect(User.count).to eq(0)
  end
end
```

Testi menee läpi.

Tehdään sitten testi kunnollisella salasanalla:

```ruby
  it "is saved with a proper password" do
    user = User.create :username => "Pekka", :password => "secret1", :password_confirmation => "secret1"

    expect(user.valid?).to eq(true)
    expect(User.count).to eq(1)
  end
```

Testin ensimmäinen "ekspektaatio" varmistaa, että luodun olion validointi on onnistunut, eli että metodi <code>valid?</code> palauttaa true. Toinen ekspektaatio taas varmistaa, että tietokannassa olevien olioiden määrä on yksi.

On huomattavaa, että Rspec nollaa tietokannan aina ennen jokaisen testin ajamista, eli jos teemme uuden testin, jossa tarvitaan Pekkaa, on se luotava uudelleen:

```ruby
  it "with a proper password and two ratings, has the correct average rating" do
    user = User.create :username => "Pekka", :password => "secret1", :password_confirmation => "secret1"
    rating = Rating.new :score => 10
    rating2 = Rating.new :score => 20

    user.ratings << rating
    user.ratings << rating2

    expect(user.ratings.count).to eq(2)
    expect(user.average_rating).to eq(15.0)
  end
```

Kuten arvata saattaa, ei testin alustuksen (eli testattavan olion luomisen) toistaminen ole järkevää, ja yhteinen osa voidaan helposti eristää. Tämä tapahtuu esim. tekemällä samanlaisen alustuksen omaavalle osalle testeistä oma describe-lohko, jonka alkuun määritellään ennen jokaista testiä suoritettava let-komento, joka alustaa user-muuttujan uudelleen jokaista testiä ennen:

```ruby
describe User do
  it "has the username set correctly" do
    user = User.new :username => "Pekka"

    user.username.should == "Pekka"
  end

  it "is not saved without a proper password" do
    user = User.create :username => "Pekka"

    expect(user.valid?).to be(false)
    expect(User.count).to eq(0)
  end

  describe "with a proper password" do
    let(:user){ User.create :username => "Pekka", :password => "secret1", :password_confirmation => "secret1" }

    it "is saved" do
      expect(user.valid?).to be(true)
      expect(User.count).to eq(1)
    end

    it "and with two ratings, has the correct average rating" do
      rating = Rating.new :score => 10
      rating2 = Rating.new :score => 20

      user.ratings << rating
      user.ratings << rating2

      expect(user.ratings.count).to eq(2)
      expect(user.average_rating).to eq(15.0)
    end
  end
end
```

Siitä huolimatta, että muuttujan alustus on nyt vain yhdessä paikassa koodia, suoritetaan alustus uudelleen ennen jokaista metodia. Huom: metodi let suorittaa olion alustuksen vasta kun olioa tarvitaan oikeasti!

Erityisesti vanhemmissa Rspec-testeissä näkee tyyliä, jossa testeille yhteinen alustus tapahtuu <code>before :each</code> -lohkon avulla. Tällöin testien yhteiset muuttujat on määriteltävä instanssimuuttujiksi, eli tyyliin <code>@user</code>.

Testien ja describe-lohkojen nimien valinta ei ole ollut sattumanvaraista. Määrittelemällä testauksen tulos formaattiin "documentation" (parametri -f d), saadaan testin tulos ruudulle mukavassa muodossa:

```ruby
mluukkai@e42-17:~/WadRoR/ratebeer$ rspec spec -f d
Rack::File headers parameter replaces cache_control after Rack 1.5.

User
  without a proper password is not saved
  with a proper password
    is saved
    and with two ratings, has the correct average rating

Finished in 0.53934 seconds
3 examples, 0 failures
```

Pyrkimyksenä onkin kirjoittaa testien nimet siten, että testit suorittamalla saadaan ohjelmasta mahdollisimman ihmisluettava "spesifikaatio".

Voit myös lisätä rivin ```-f d``` tiedostoon ```.rspec```, jolloin projektin rspec-testit näytetään aina documentation formaatissa.

> ## Tehtävä 1
>
> Lisää luokalle User testit jotka varmistavat, että liian lyhyen tai pelkästään kirjaimista muodostetun salasanan omaavan käyttäjän luominen create-metodilla ei tallenna olioa tietokantaan, ja että luodun olion validointi ei ole onnistunut

Muista aina nimetä testisi niin että ajamalla Rspec dokumentointiformaatissa, saat kieliopillisesti järkevältä kuulostavan "speksin".

> ## Tehtävä 2
>
> Luo Rspecin generaattorilla (tai käsin) testipohja luokalle Beer ja tee testit jotka varmistavat, että
> * oluen luonti ei onnistu (eli creatella ei synny validia oliota), jos sille ei anneta nimeä
> * oluen luonti ei onnistu, jos sille ei määritellä tyyliä
>
> Jälkimäinen testi ei mene läpi. Laajenna koodiasi siten, että se läpäisee testin.

## Testiympäristöt eli fixturet

Edellä käyttämämme tapa, jossa testien tarvitsemia monimutkaisia oliorakenteita luodaan testeissä käsin, ei ole välttämättä kaikissa tapauksissa järkevä. Parempi tapa on koota testiympäristön rakentaminen, eli testien alustamiseen tarvittava data omaan paikkaansa, "testifixtureen". Käytämme testien alustamiseen Railsin oletusarvoisen fixture-mekanismin sijaan FactoryGirl-nimistä gemiä, kts.
https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md

Lisätään Gemfileen seuraava

```ruby
group :test do
  gem 'factory_girl_rails'
end
```

ja päivitetään gemit komennolla <code>bundle install</code>

Tehdään fixtureja varten tiedosto spec/factories.rb ja kirjoitetaan sinne seuraava:

```ruby
FactoryGirl.define do
  factory :user do
    username "Pekka"
    password "foobar1"
    password_confirmation "foobar1"
  end

  factory :rating, :class => Rating do
    score 10
  end

  factory :rating2, :class => Rating do
    score 20
  end
end
```

Tiedostossa määritellään kolme "oliotehdasta". Ensimmäinen näistä on nimeltään user:

```ruby
  factory :user do
    username "Pekka"
    password "foobar1"
    password_confirmation "foobar1"
  end
```

Tehdasta voi käyttää luomaan luokan <code>User</code> olion. Tehtaaseen ei tarvinnut määritellä erikseen tehtaan luomien olioiden luokkaa, sillä FactoryGirl päättelee sen suoraan käytettävän fixtuurin nimestä <code>user</code>.

Tiedostossa määritellään myös kaksi erinimistä reittausolioita generoivaa tehdasta <code>rating</code> ja <code>rating2</code>. FactoryGirl ei osaa päätellä näiden tyyppiä suoraan tehtaan nimestä, joten se on määriteltävä eksplisiittisesti.

Määriteltyjä tehtaita voidaan pyytää luomaan olioita seuraavasti:

```ruby
  user = FactoryGirl.create(:user)
  rating = FactoryGirl.create(:rating)
```

FactoryGirlin tehdasmetodin kutsuminen luo olion automaattisesti testausympäristön tietokantaan.

Muutetaan nyt testimme käyttämään FactoryGirliä.

```ruby
  describe "with a proper password" do
    let(:user){ FactoryGirl.create(:user) }

    it "is saved" do
      expect(user.valid?).to be(true)
      expect(User.count).to eq(1)
    end

    it "and with two ratings, has the correct average rating" do
      user.ratings << FactoryGirl.create(:rating)
      user.ratings << FactoryGirl.create(:rating2)

      expect(user.ratings.count).to eq(2)
      expect(user.average_rating).to eq(15.0)
    end
  end
```



Testi on nyt siistiytynyt jossain määrin.

Huom: samaa tehdasta voidaan pyytää luomaan useita oliota:

``` ruby
  r1 = FactoryGirl.create(:rating)
  r2 = FactoryGirl.create(:rating)
  r3 = FactoryGirl.create(:rating)
```

nyt luotaisiin kolme eri olioa jotka ovat kaikki samansisältöistä. Myös tehtaalta <code>user</code> voitaisiin pyytää kahta eri olioa. Tämä kuitenkin aiheuttaisi poikkeuksen, sillä User-olioiden validointi edellyttää että username on yksikäsitteinen ja tehdas luo oletusarvoisesti aina "Pekka"-nimisen käyttäjän.

## Käyttäjän lempiolut, -panimo ja -oluttyyli

Toteutetaan seuraavaksi test driven -tyylillä (tai behaviour driven niinkuin rspecin luojat sanoisivat) käyttäjälle metodit, joiden avulla saadaan selville käyttäjän lempiolut, lempipanimo ja lempioluttyyli käyttäjän antamien reittausten perusteella.

Oikeaoppisessa TDD:ssä ei tehdä yhtään koodia ennenkuin minimaalinen testi sen pakottaa. Tehdäänkin ensin testi, jonka avulla vaaditaan että User-olioilla on metodi <code>favorite_beer</code>:

```ruby
  it "has method for determining the favorite_beer" do
    user = FactoryGirl.create(:user)
    user.should respond_to :favorite_beer
  end
```

Testi ei mene läpi, eli lisätään luokalle User metodin runko:

```ruby
class User < ActiveRecord::Base
  # ...

  def favorite_beer
  end
end
```

Testi menee nyt läpi. Lisätään seuraavaksi testi, joka varmistaa, että ilman reittauksia, ei käyttäjllä ole mieliolutta, eli että metodi palauttaa nil:

```ruby
  it "without ratings does not have a favourite beer" do
    user = FactoryGirl.create(:user)
    expect(user.favorite_beer).to eq(nil)
  end
```

Testi menee läpi sillä rubyn metodit palauttavat oletusarvoisesti nil.

Refaktoroidaan testiä hieman lisäämällä juuri kirjoitetulle kahdelle testille oma describe-lohko

```ruby
  describe "favorite beer" do
    let(:user){FactoryGirl.create(:user) }

    it "has method for determining one" do
      user.should respond_to :favorite_beer
    end

    it "without ratings does not have one" do
      expect(user.favorite_beer).to eq(nil)
    end
  end
```

Lisätään sitten testi, joka varmistaa että jos reittauksia on vain yksi, osaa metodi palauttaa reitatun oluen. Testiä varten siis tarvitsemme reittausolion lisäksi panimo-oluen, johon reittaus liittyy. Laajennetaan ensin hieman fikstuureja, lisätään seuraavat:

```ruby
  factory :brewery do
    name "anonymous"
    year 1900
  end

  factory :beer do
    name "anonymous"
    brewery
    style "Lager"
  end
```

Koodi create(:brewery) luo panimon jonka nimi on anonymous ja perustamisvuosi 1900. Vastaavasti create(:beer) luo oluen, jonka tyyli on Lager ja nimi anonymous ja oluelle luodaan panimo, johon olut liittyy. Jos määrittelylohkossa ei olisi brewery:ä, tulisi oluen panimon arvoksi <code>nil</code> eli olut ei liittyisi mihinkään panimoon. Aikaisemmin tehty create(:rating) luo reittausolion jolle asetetaan scoreksi 10, mutta reittausta ei liitetä automaattisesti olueeseen eikä käyttäjään.

Voimme nyt luoda testissä FactoryGirlin avulla oluen (johon automaattisesti liittyy panimo) sekä reittauksen joka liittyy luotuun olueeseen ja käyttäjään:

```ruby
    it "is the only rated if only one rating" do
      beer = FactoryGirl.create(:beer)
      rating = FactoryGirl.create(:rating, :beer => beer, :user => user)

      # jatkuu...
    end
```

Alussa siis luodaan olut, sen jälkeen rating. <code>create</code>-metodille annetaan nyt parametreiksi olut- ja käyttäjäoliot, joihin reittaus liitetään.

Luotu reittaus siis liittyy käyttäjään ja on käyttäjän ainoa reittaus. Testi siis lopulta odottaa, että reittaukseen liittyvä olut on käyttäjän lemipiolut:

```ruby
    it "is the only rated if only one rating" do
      beer = FactoryGirl.create(:beer)
      rating = FactoryGirl.create(:rating, :beer => beer, :user => user)

      expect(user.favorite_beer).to eq(beer)
    end
```

Testi ei mene läpi, sillä metodimme ei vielä tee mitään ja sen paluuarvo on siis aina <code>nil</code>.
Tehdään [TDD:n hengen mukaan](http://codebetter.com/darrellnorton/2004/05/10/notes-from-test-driven-development-by-example-kent-beck/) ensin "huijattu ratkaisu", eli ei vielä yritetäkään tehdä lopullista toimivaa versiota:

```ruby
class User < ActiveRecord::Base
  # ...

  def favorite_beer
    return nil if ratings.empty?   # palautetaan nil jos reittauksia ei ole
    ratings.first.beer             # palataan ensimmaiseen reittaukseen liittyvä olut
  end
end
```

Tehdään vielä testi, joka pakottaa meidät tekemään metodille kunnollinen toteutus [(ks. triangulation)](http://codebetter.com/darrellnorton/2004/05/10/notes-from-test-driven-development-by-example-kent-beck/):

```ruby
    it "is the one with highest rating if several rated" do
      beer1 = FactoryGirl.create(:beer)
      beer2 = FactoryGirl.create(:beer)
      beer3 = FactoryGirl.create(:beer)
      rating1 = FactoryGirl.create(:rating, :beer => beer1, :user => user)
      rating2 = FactoryGirl.create(:rating, :score => 25,  :beer => beer2, :user => user)
      rating3 = FactoryGirl.create(:rating, :score => 9, :beer => beer3, :user => user)

      expect(user.favorite_beer).to eq(beer2)
    end
```

Ensin luodan kolme olutta ja sen jälkeen oluisiin sekä user-olioon liittyvät reittaukset. Ensimmäinen reittaus saa reittauksiin määritellyn oletuspisteytyksen eli 10 pistettä. Toiseen ja kolmanteen reittaukseen score annetaan parametrina.

Testi ei luonnollisesti mene vielä läpi, sillä favorite_beer metodin toteutus jätettiin aiemmin puutteelliseksi.

Muuta metodin toteutus nyt seuraavanlaiseksi:

```ruby
  def favorite_beer
    return nil if ratings.empty?
    ratings.sort_by{ |r| r.score }.last.beer
  end
```

eli ensin järjestetään reittaukset scoren perusteella, otetaan reittauksista viimeinen eli korkeimman scoren omaava ja palautetaan siihen liittyvä olut.

## Testien apumetodit

Huomaamme, että testissä tarvittavien oluiden rakentamisen tekevä koodi on hieman ikävä. Voisimme konfiguroida FactoryGirliin oluita, joihin liittyisi reittaus. Päätämme kuitenkin tehdä testitiedoston puolelle apumetodin <code>create_beer_with_rating</code> joka luo reittauksellisen oluen:

```ruby
    def create_beer_with_rating(score,  user)
      beer = FactoryGirl.create(:beer)
      FactoryGirl.create(:rating, :score => score,  :beer => beer, :user => user)
      beer
    end
```

Apumetodia käyttämällä saamme siistityksi testiä

```ruby
    it "is the one with highest rating if several rated" do
      create_beer_with_rating 10, user
      best = create_beer_with_rating 25, user
      create_beer_with_rating 7, user

      expect(user.favorite_beer).to eq(best)
    end
```

Apumetodeja siis voi (ja kannattaa) määritellä rspec-tiedostoihin.

Parannetaan vielä edellistä hiukan määrittelemällä toinenkin metodi <code>create_beers_with_ratings</code>, jonka avulla voi luoda useita reitattuja oluita. Metodi saa reittaukset taulukon tapaan käyttäytyvän vaihtuvamittaisen parametrilistan (ks. http://www.ruby-doc.org/docs/ProgrammingRuby/html/tut_methods.html, kohta "Variable-Length Argument Lists") avulla.

Seuraavassa koko mielioluen testaukseen liittyvä koodi:

```ruby
  describe "favorite beer" do
    let(:user){FactoryGirl.create(:user) }

    it "has method for determining one" do
      user.should respond_to :favorite_beer
    end

    it "without ratings does not have one" do
      expect(user.favorite_beer).to eq(nil)
    end

    it "is the only rated if only one rating" do
      beer = create_beer_with_rating 10, user

      expect(user.favorite_beer).to eq(beer)
    end

    it "is the one with highest rating if several rated" do
      create_beers_with_ratings 10, 20, 15, 7, 9, user
      best = create_beer_with_rating 25, user

      expect(user.favorite_beer).to eq(best)
    end

    def create_beers_with_ratings(*scores, user)
      scores.each do |score|
        create_beer_with_rating score, user
      end
    end

    def create_beer_with_rating(score,  user)
      beer = FactoryGirl.create(:beer)
      FactoryGirl.create(:rating, :score => score,  :beer => beer, :user => user)
      beer
    end
  end
```

> # Tehtävä 3
>
> Tee seuraavaksi TDD-tyylillä User-olioille metodi <code>favorite_style</code>, joka palauttaa tyylin, jonka oluet ovat saaneet käyttäjältä keskimäärin korkeimman reittauksen. Lisää käyttäjän sivulle tieto käyttäjän mielityylistä.
>
> Älä tee kaikkea yhteen metodiin, vaan määrittele sopivia apumetodeja! Jos huomaat metodisi olevan yli 5 riviä pitkä, teet asioita todennäköisesti joko liikaa tai liian kankeasti, joten refaktoroi koodiasi. Rubyn kokoelmissa on paljon tehtävään hyödyllisiä apumetodeja, ks. http://ruby-doc.org/core-2.0/Enumerable.html

> # Tehtävä 4
>
> Tee vielä TDD-tyylillä User-olioille metodi <code>favorite_brewery</code>, joka palauttaa panimon, jonka oluet ovat saaneet käyttjältä keskimäärin korkeimman reittauksen.  Lisää käyttäjän sivulle tieto käyttäjän mielipanimosta.
>
> Tee tarvittaessa apumetodeja rspec-tiedostoon, jotta testisi pysyvät siisteinä. Jos apumetodeista tulee samantapaisia, ei kannata copypasteta vaan yleistää ne. Huomaa, että koska edellä esimerkissä määriteltiin apumetodit describe-lohkon sisällä, eivät ne näy muissa describe-lohkoissa oleviin testeihin. Eli jos käytät apumetodeja useissa describeissä, tuo apumetodit ylemmälle tasolle.

Metodien <code>favorite_brewery</code> ja <code>favorite_style</code> tarvitsema toiminnallisuus on hyvin samankaltainen ja metodit ovatkin todennäköisesti enemmän tai vähemmän copy-pastea. Viikolla 5 tulee olemaan esimerkki koodin siistimisestä.

## Capybara

Siirrymme seuraavaksi järjestelmätason testaukseen. Kirjoitamme siis automatisoituja testejä, jotka käyttävät sovellusta normaalin käyttäjän tapaan selaimen kautta. De facto -tapa Rails-sovelluste selaintason testaamiseen on Capybaran https://github.com/jnicklas/capybara käyttö. Itse testit kirjoitetaan edelleen Rspecillä, capybara tarjoaa ainoastaan selaimen simuloinnin.

Lisätään Gemfileen (test-scopeen) gemit 'capybara' ja 'launchy' eli test-scopen pitäisi näyttää seuraavalta:

```ruby
group :test do
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'launchy'
end
```

Jotta gemit saadaan käyttöön, suoritetaan tuttu komento <code>bundle install</code>. Tiedoston  spec/spec_helper.rb-tiedoston yläosaan on myös lisättävä rivi

    require 'capybara/rspec'

Nyt olemme valmiina ensimmäiseen selaintason testiin.

Selaintason testit on tapana sijoittaa hakemistoon spec/features. Yksikkötestit organisoidaan useimmiten siten, että kutakin luokkaa testaavat testit tulevat omaan tiedostoonsa. Ei ole aina itsestään selvää, miten selaimen kautta suoritettavat käyttäjätason testit kannattaisi organisoida. Yksi vaihtoehto on käyttää kontrollerikohtaisia tiedostoja, toinen taas jakaa testit eri tiedostoihin järjestelmän eri toiminnallisuuksien mukaan.

Aloitetaan testien määrittely panimoihin liittyvästä toiminnallisuudesta, luodaan tiedosto spec/features/breweries_page_spec.rb:

```ruby
require 'spec_helper'

describe "Breweries page" do
  it "should not have any before been created" do
    visit breweries_path
    expect(page).to have_content 'Listing breweries'
    expect(page).to have_content 'number of breweries 0'
  end
end
```

Testi aloittaa navigoimalla <code>visit</code>-metodia käyttäen panimoiden listalle. Kuten huomaamme, Railsin polkuapumetodit ovat myös Rspec-testien käytössä. Tämän jälkeen tarkastetaan sisältääkö renderöity sivu tekstin 'Listing breweries' ja tiedon siitä että panimoiden lukumäärä on 0. Capybara asettaa sen sivun jolla testi kulloinkin on muuttujaan <code>page</code>.

Testejä tehdessä tulee (erittäin) usein tilanteita, joissa olisi hyödyllistä nähdä page-muuttujan kuvaaman sivun html-muotoinen lähdekoodi. Tämä onnistuu lisäämällä testiin komento <code>puts page.html</code>

Toinen vaihoehto on lisätä testiin komento <code>save_and_open_page</code>, joka tallettaa ja avaa kyseisen sivun <code>BROWSER</code>-ympäristömuuttujan määrittelemässä selaimessa. Esim. laitoksen koneilla saat määriteltyä oletusselaimeksi chromiumin komennolla:

    export BROWSER='/usr/bin/chromium-browser'

Määrittely on voimassa vain siinä shellissä jossa teet sen. Jos haluat määrittelystä pysyvän, lisää se tiedostoon .bashrc

Lisätään testi, joka testaa tilannetta, jossa tietokannassa on 3 panimoa:

```ruby
  it "lists the existing breweries and their total number" do
    breweries = ["Koff", "Karjala", "Schlenkerla"]
    breweries.each do |brewery|
      FactoryGirl.create(:brewery, :name => brewery)
    end

    visit breweries_path

    expect(page).to have_content "number of breweries #{breweries.count}"

    breweries.each do |brewery|
      expect(page).to have_content brewery
    end
  end
```

Lisätään vielä testi, joka tarkastaa, että panimoiden sivulta pääsee linkkiä klikkaamalla yksittäisen panimon sivulle. Hyödynnämme tässä capybaran metodia <code>click_link</code> jonka avulla on mahdollista klikata sivulla olevaa linkkiä:

```ruby
  it "allows user to navigate to page of a Brewery" do
    breweries = ["Koff", "Karjala", "Schlenkerla"]
    year = 1896
    breweries.each do |brewery|
        FactoryGirl.create(:brewery, :name => brewery, :year => year += 1)
    end

    visit breweries_path

    click_link "Koff"

    expect(page).to have_content "Koff"
    expect(page).to have_content "Established year 1897"
  end
```

Testi ei kuitenkaan mene läpi. Virheilmoitus on seuraava

```ruby
  1) Breweries page allows user to navigate to page of a Brewery
     Failure/Error: click_link "Koff"
     Capybara::ElementNotFound:
       Unable to find link "Koff"
     # ./spec/features/breweries_page_spec.rb:18:in `block (2 levels) in <top (required)>'
```

eli capybara ei löydä panimoiden sivulta linkkiä, jonka tekstinä on "Koff". Emme ole varmoja mistä virhe johtuu, joten lisätään testiin juuri ennen epäonnistuvaa <code>click_link</code>-komentoa sivun selaimeen avaava komento <code>save_and_open_page</code>, ja ajetaan testi uudelleen. Avautuva sivu on seuraavanlainen

![kuva](http://www.cs.helsinki.fi/u/mluukkai/wadror/ratebeer-w4-1.png)

Eli toisin kuin muistimme, panimoiden sivulla panimoista ei ole vielä tehty klikattavia.

> # Tehtävä 5
>
> Muokkaa panimojen listaavaa sivua siten, että testi menee läpi, eli muuta panimon nimi linkiksi joka vie panimon sivulle.

Kahdessa viimeisessä testissämme on sama alkuosa, eli aluksi luodaan kolme panimoa ja navigoidaan panimojen sivulle.

Seuraavassa vielä refaktoroitu lopputulos, jossa yhteisen alustuksen omaavat testit on siirretty omaan describe-lohkoon, jolle on määritelty <code>before :each</code> -lohko alustusta varten.

```ruby
require 'spec_helper'

describe "Breweries page" do
  it "should not have any before been created" do
    visit breweries_path
    expect(page).to have_content 'Listing breweries'
    expect(page).to have_content 'number of breweries 0'

  end

  describe "when breweries exists" do
    before :each do
      @breweries = ["Koff", "Karjala", "Schlenkerla"]
      year = 1896
      @breweries.each do |brewery|
        FactoryGirl.create(:brewery, :name => brewery, :year => year += 1)
      end

      visit breweries_path
    end

    it "lists the breweries and their total number" do
      expect(page).to have_content "number of breweries #{@breweries.count}"
      @breweries.each do |brewery|
        expect(page).to have_content brewery
      end
    end

    it "allows user to navigate to page of a Brewery" do
      click_link "Koff"

      expect(page).to have_content "Koff"
      expect(page).to have_content "Established year 1897"
    end

  end
end
```

Huomaa, että describe-lohkon sisällä oleva <code>before :each</code> suoritetaan kertaalleen ennen jokaista describen alla määriteltyä testiä ja jokainen testi alkaa tilanteesta, missä tietokanta on tyhjä.

## Käyttäjän toiminnallisuuden testaaminen

Siirrytään käyttäjän toiminnallisuuteen, luodaan näitä varten tiedosto features/users_spec.rb, ja aloitetaan testillä, joka varmistaa, että käyttäjä pystyy kirjautumaan järjestelmään:

```ruby
require 'spec_helper'

describe "User" do
  before :each do
    FactoryGirl.create :user
  end

  describe "who has signed up" do
    it "can sign in with right credentials" do
      visit signin_path
      fill_in('username', :with => 'Pekka')
      fill_in('password', :with => 'foobar1')
      click_button('Log in')

      expect(page).to have_content 'Welcome back!'
      expect(page).to have_content 'Pekka'
    end
  end
end
```

Testi demonstroi lomakkeen kanssa käytävää interaktiota, komento <code>fill_in</code> etsii lomakkeesta id-kentän perusteella tekstikenttää, jolle se syöttää parametrina annetun arvon. <code>click_button</code> toimii kuten arvata saattaa, eli painaa sivulta etsittävää painiketta.

Capybaran dokumentaation kohdasta the DSL ks. https://github.com/jnicklas/capybara#the-dsl löytyy lisää esimerkkejä mm. sivulla olevien elementtien etsimiseen ja esim. lomakkeiden käyttämiseen.

Tehdään vielä muutama testi käyttäjälle. Virheellisen salasanan syöttämisen pitäisi ohjata takaisin kirjaantumissivulle:

```ruby
  describe "who has signed up" do
    # ...

    it "is redirected back to sign in form if wrong credentials given" do
      visit signin_path
      fill_in('username', :with => 'Pekka')
      fill_in('password', :with => 'wrong')
      click_button('Log in')

      expect(current_path).to eq(signin_path)
      expect(page).to have_content 'username and password do not match'
    end
  end
```

Testi hyödyntää metodia <code>current_path</code>, joka palauttaa sen polun minne testin suoritus on metodin kutsuhetkellä päätynyt. Metodin avulla varmistetaan, että käyttäjä uudelleenohjataan takaisin kirjautumissivulle epäonnistuneen kirjautumisen jälkeen.

Ei ole aina täysin selvää missä määrin sovelluksen bisneslogiikkaa kannattaa testata selaintason testien kautta. Edellä tekemämme käyttäjä-olion suosikkioluen, panimon ja oluttyylin selvittävien logiikoiden testaaminen on ainakin viisainta tehdä yksikkötesteinä.

Käyttäjätason testein voidaan esim. varmistua, että sivuilla näkyy sama tilanne, joka tietokannassa on, eli esim. panimoiden testissä tietokantaan generoitiin 3 panimoa ja sen jälkeen testattiin että ne kaikki renderöityvät panimoiden listaan.

Myös sivujen kautta tehtävät lisäykset ja poistot kannattaa testata. Esim. seuraavassa testataan, että uuden käyttäjän rekisteröityminen lisää järjestelmän käyttäjien lukumäärää yhdellä:

```ruby
  it "when signed up with good credentials, is added to the system" do
    visit signup_path
    fill_in('user_username', :with => 'Brian')
    fill_in('user_password', :with => 'secret55')
    fill_in('user_password_confirmation', :with => 'secret55')

    expect{
      click_button('Create User')
    }.to change{User.count}.by(1)
  end
```

Huomaa, että lomakkeen kentät määriteltiin fill_in-metodeissa hieman eri tavalla kuin kirjautumislomakkeessa. Kenttien id:t voi ja kannattaa aina tarkastaa katsomalla sivun lähdekoodia selaimen view page source -toiminnolla.

Testi siis odottaa, että create user -painikkeen klikkaaminen muuttaa tietokantaan talletettujen käyttäjien määrää yhdellä. Syntaksi on hieno, mutta kestää hetki ennen kuin koko Rspecin ilmaisuvoimainen kieli alkaa tuntua rutiinilta. Rspecin dokumentaatio kertoo lisää rspecin valmiista matchereistä, esim. change-oliosta, ks. https://www.relishapp.com/rspec/rspec-expectations/v/2-14/docs/built-in-matchers

Edellinen testi siis testasi, että selaimen tasolla tehty operaatio luo olion tietokantaan. Onko vielä tehtävä erikseen testi, joka testaa että luodulla käyttäjätunnuksella voi kirjautua järjestelmään? Kenties, edellinen testihän ei ota kantaa siihen tallentuiko käyttäjä-olio tietokantaan oikein.

Potentiaalisia testauksen kohteita on kuitenkin niin paljon, että kattava testaus on mahdotonta ja testejä tulee pyrkiä ensisijaisesti kirjoittamaan niille asioille, jotka ovat riskialttiita hajoamaan.

Tehdään vielä testi oluen reittaamiselle. Tehdään testiä varten oma tiedosto spec/features/ratings_spec.rb

```ruby
require 'spec_helper'

describe "Rating" do
  let!(:brewery) { FactoryGirl.create :brewery, :name => "Koff" }
  let!(:beer1) { FactoryGirl.create :beer, :name => "iso 3", :brewery => brewery }
  let!(:beer2) { FactoryGirl.create :beer, :name => "Karhu", :brewery => brewery }
  let!(:user) { FactoryGirl.create :user }

  before :each do
    visit signin_path
    fill_in('username', :with => 'Pekka')
    fill_in('password', :with => 'foobar1')
    click_button('Log in')
  end

  it "when given, is registered to the beer and user who is signed in" do
    visit new_rating_path
    select(beer1.to_s, :from => 'rating[beer_id]')
    fill_in('rating[score]', :with => '15')

    expect{
      click_button "Create Rating"
    }.to change{Rating.count}.from(0).to(1)

    expect(user.ratings.count).to eq(1)
    expect(beer1.ratings.count).to eq(1)
    expect(beer1.average_rating).to eq(15.0)
  end
end
```

Testin before-lohkossa on koodi, jonka avulla käyttäjä kirjautuu järjestelmään. On todennäköistä, että samaa koodilohkoa tarvittaan useissa eri testitiedostoissa. Useassa eri paikassa tarvittava testikoodi kannattaa eristää omaksi apumetodikseen ja sijoittaa moduliin, jonka kaikki sitä tarvitsevat testitiedostot voivat sisällyttää itselleen. Luodaan moduli tiedostoon /spec/support/helpers/own_test_helper.rb ja siirretään kirjautumisesta vastaava koodi sinne:

```ruby
module OwnTestHelper
  def sign_in(username, password)
    visit signin_path
    fill_in('username', :with => username)
    fill_in('password', :with => password)
    click_button('Log in')
  end
end
```

Otetaan modulin määrittelemä metodi käyttöön testeissä:

```ruby
describe "Rating" do
  include OwnTestHelper

  let!(:brewery) { FactoryGirl.create :brewery, :name => "Koff" }
  let!(:beer1) { FactoryGirl.create :beer, :name => "iso 3", :brewery => brewery }
  let!(:beer2) { FactoryGirl.create :beer, :name => "Karhu", :brewery => brewery }
  let!(:user) { FactoryGirl.create :user }

  before :each do
    sign_in 'Pekka', 'foobar1'
  end

  # ...
end
```

ja

```ruby
describe "User" do
  include OwnTestHelper

  before :each do
    FactoryGirl.create :user
  end

  describe "who has signed up" do
    it "can sign in with right credentials" do
      sign_in 'Pekka', 'foobar1'

      expect(page).to have_content 'Welcome back!'
      expect(page).to have_content 'Pekka'
    end

    it "is redirected back to sign in form if wrong credentials given" do
      sign_in 'Pekka', 'wrong'

      expect(current_path).to eq(signin_path)
      expect(page).to have_content 'username and password do not match'
    end
  end

  # ...
end
```

Kirjautumisen toteutuksen siirtäminen apumetodiin siis kasvattaa myös testien luettavuutta, ja jos kirjautumissivun toiminnallisuus myöhemmin muuttuu, on testien ylläpito helppoa, koska muutoksia ei tarvita kuin yhteen kohtaan.

> ## Tehtävä 6
>
> Tee testi joka varmistaa, että tietokannassa olevat reittaukset näytetään sivulla ratings

> ## Tehtävä 7
>
> Tee testi joka varmistaa, että käyttäjän reittaukset näytetään käyttäjän sivulla

> ## Tehtävä 8
>
>  Tee testi, joka varmistaa että käyttäjän poistaessa oma reittauksensa, se poistuu tietokannasta

> ## Tehtävä 9
>
> Tee testi, joka varmistaa että käyttäjä voi lisätä järjestelmään oluen (lisäys vie ne tietokantaan)

> ## Tehtävä 10
>
> Laajenna käyttäjän sivua siten, että siellä näytetään käyttäjän lempioluttyyli sekä lempipanimo. Tee ominaisuudelle myös selaimen capybara-testit. Monimutkaista laskentaa testeissä ei kannata testata sillä yksikkötestit varmistavat sen jo riittävissä määrin.

## RSpecin syntaksin uudet tuulet

Kuten kirjoittaessamme ensimmäistä testiä totesimme, on Rspecissä useita tapoja saman asian ilmaisemiseen. Tehdään nyt muutama yksikkötesti Brewery-modelille. Aloitetaan generoimalla testipohja komennolla

    rails generate rspec:model brewery

Kirjoitetaan ensin "vanhahtavalla" should-syntaksilla (ks. https://github.com/rspec/rspec-expectations/blob/master/Should.md) testi, joka varmistaa että <code>create</code> asettaa panimon nimen ja perustamisvuoden oikein ja, että olio tallettuu kantaan:

```ruby
require 'spec_helper'

describe Brewery do
  it "has the name and year set correctly and is saved to database" do
    brewery = Brewery.create :name => "Schlenkerla", :year => 1674

    brewery.name.should == "Schlenkerla"
    brewery.year.should == 1674
    brewery.valid?.should == true
  end
end
```

Viimeinen ehto, eli onko panimo validi ja tallentunut kantaan on ilmaistu kömpelösti. Koska panimon metodi <code>valid?</code> palauttaa totuusarvon voimme ilmaista asian myös seuraavasti (ks http://rubydoc.info/gems/rspec-expectations/RSpec/Matchers):

```ruby
  it "has the name and year set correctly and is saved to database" do
    brewery = Brewery.create :name => "Schlenkerla", :year => 1674

    brewery.name.should == "Schlenkerla"
    brewery.year.should == 1674
    brewery.should be_valid
  end
```

Käytettäessä <code>be_something</code> predikaattimatcheria, rspec olettaa, että oliolla on totuusarvoinen metodi nimeltään <code>something?</code>, eli kyse on konventioiden avulla aikaansaadusta "magiasta".
Ilmaisu <code>brewery.should be_valid</code> on lähempänä luonnollista kieltä, joten se on ehdottomasti suositeltavampi. Testi, joka testaa että panimoa ei voida tallettaa ilman nimeä voidaan tehdä seuraavasti käyttäen shouldin negaatiota eli metodia <code>should_not</code>:

```ruby
  it "without a name is not valid" do
    brewery = Brewery.create  :year => 1674

    brewery.should_not be_valid
  end
```

Myös muoto <code>brewery.should be_invalid</code> toimisi täsmälleen samoin.

Käytimme yllä shouldin sijaan <code>expect</code>-syntaksia (ks. http://rubydoc.info/gems/rspec-expectations/) joka tuntuu vallanneen alaa shouldilta (vuonna 2010 Rspecin kirjoittamassa kirjassa http://pragprog.com/book/achbd/the-rspec-book käytetään vielä lähes yksinomaan shouldia!). Testimme expectillä olisi seuraava:

```ruby
  it "has the name and year set correctly and is saved to database" do
    brewery = Brewery.create :name => "Schlenkerla", :year => 1674

    expect(brewery.name).to eq("Schlenkerla")
    expect(brewery.year).to eq(1674)
    expect(brewery).to be_valid
  end

  it "without a name is not valid" do
    brewery = Brewery.create  :year => 1674

    expect(brewery).not_to be_valid
  end
```

Voisimme kirjoittaa rivin <code>expect(brewery.year).to eq(1674)</code> myös muodossa <code>expect(brewery.year).to be(1674)</code> sen sijaan <code>expect(brewery.name).to be("Schlenkerla")</code> ei toimisi, virheilmoitus antaakin vihjeen mistä on kysymys:

```ruby
  1) Brewery has the name and year set correctly and is saved to database
     Failure/Error: expect(brewery.name).to be("Schlenkerla")

       expected #<String:44715020> => "Schlenkerla"
            got #<String:47598800> => "Schlenkerla"

       Compared using equal?, which compares object identity,
       but expected and actual are not the same object. Use
       `expect(actual).to eq(expected)` if you don't care about
       object identity in this example.
```

Eli <code>be</code> vaatii että kysessä ovat samat oliot, pelkkä olioiden samansisältöisyys ei riitä, kokonaislukuolioita, joiden suuruus on 1674 on rubyssä vaan yksi, sen takia be toimii vuoden yhteydessä, sen sijaan merkkijonoja joiden sisältö on "Schlenkerla" voi olla mielivaltaisen paljon, eli merkkijonoja vertailtaessa on käytettävä matcheria <code>eq</code>.

Testiä on mahdollisuus vielä hioa käyttämällä Rspec 2:n (https://www.relishapp.com/rspec/rspec-core/v/2-11/docs) mukanaan tuomaa syntaksia. Jokaisessa testimme ehdossa testauksen kohde on sama, eli muuttujaan <code>brewery</code> talletettu olio. Uusi <code>subject</code> syntaksi mahdollistaakin sen, että testauksen kohde määritellään vain kerran, ja sen jälkeen siihen ei ole tarvetta viitata eksplisiittisesti. Seuraavassa testi uudelleenmuotoiltuna uutta syntaksia käyttäen:

```ruby
  describe "when initialized with name Schlenkerla and year 1674" do
    subject{ Brewery.create :name => "Schlenkerla", :year => 1674 }

    it { should be_valid }
    its(:name) { should eq("Schlenkerla") }
    its(:year) { should eq(1674) }
  end
```

Testi on entistä kompaktimpi ja luettavuudeltaan erittäin sujuva. Mikä parasta, myös dokumenttiformaatissa generoitu testiraportti on hyvin luonteva:

```ruby
Brewery
  when initialized with name Schlenkerla and year 1674
    should be valid
    name
      should eq "Schlenkerla"
    year
      should eq 1674
```

Lisää subject-syntaktista osoitteessa
https://www.relishapp.com/rspec/rspec-core/v/2-11/docs/subject

Neuvoja hyvän Rspecin kirjoittamiseen antaa myös sivu
http://betterspecs.org/

## Testauskattavuus

Testien rivikattavuus (line coverage) mitataa kuinka monta prosenttia ohjelman koodiriveistä tulee suoritettua testien suorituksen yhteydessä. Rails-sovelluksen testikattavuus on helppo mitata simplecov-gemin avulla, ks. https://github.com/colszowka/simplecov

Gem otetaan käyttöön lisäämällä Gemfilen test -scopeen rivi

    gem 'simplecov', :require => false

ja lisätään spec_helper.rb:n alkuun, kahdeksi ensimmäiseksi riviksi seuraavat:

```ruby
require 'simplecov'
SimpleCov.start
```

Sitten ajetaan testit

```ruby
mluukkai@e42-17:~/WadRoR/ratebeer$ rspec spec/
Rack::File headers parameter replaces cache_control after Rack 1.5.
.........................

Finished in 5.05 seconds
25 examples, 0 failures

Randomized with seed 27088

Coverage report generated for Cucumber Features, RSpec to /home/mluukkai/WadRoR/foo/coverage. 360 / 516 LOC (69.77%) covered.
covered.
```

Testien rivikattavuus on siis 69.77 prosenttia. Tarkempi raportti on nähtävissä selaimella osoitteesta coverage/index.html. Kuten kuva paljastaa, on suuria osia ohjelmasta vielä täysin testaamatta:

![kuva](http://www.cs.helsinki.fi/u/mluukkai/wadror/ratebeer-w4-2.png)

Suurikaan rivikattavuus ei tietysti vielä takaa että testit testaavat järkeviä asioita. Helposti mitattavana metriikkana se on kuitenkin parempi kuin ei mitään ja näyttää ainakin ilmeisimmät puutteet testeissä.

> ## Tehtävä 11
>
> Ota simplecov käyttöön ohjelmassasi

## Jatkuva integraatio

[Jatkuvalla integraatiolla](http://martinfowler.com/articles/continuousIntegration.html) (engl. continuous integration) tarkoitetaan käytännettä, jossa ohjelmistokehittäjät integroivat koodin tekemät muutokset yhteiseen kehityshaaraan mahdollisimman usein. Periaatteena on pitää ohjelman kehitysversio koko ajan toimivana eliminoiden näin raskas erillinen integrointivaihe. Toimiakseen jatkuva integraatio edellyttää kattavaa automaattisten testien joukkoa. Yleensä jatkuvan integraation yhteydessä käytetään keskitettyä palvelinta, joka tarkkailee repositorioa, jolla kehitysversio sijaitsee. Kun kehittäjä integroi koodin kehitysversioon, integraatiopalvelin huomaa muutoksen, buildaa koodin ja ajaa testit. Jos testit eivät mene läpi, tiedottaa integraatiopalvelin tästä tavalla tai toisella asianomaisia.

Travis https://travis-ci.org/ on SaaS (software as a service) -periaatteella toimiva jatkuvan integraation palvelu joka on noussut nopeasti suosituksi Open Source -projektien käytössä.

Githubissa olevat Rails-projektit on helppo asettaa Travisin tarkkailtavaksi.

> ## Tehtävä 12
>
> Tee repositorion juureen Travisia varten konfiguraatiotiedosto .travis.yml jolla on seuraava sisältö:
>
>```ruby
>language: ruby
>
>rvm:
>  - 1.9.3
>
>script:
>  - bundle exec rake db:migrate --trace
>  - RAILS_ENV=test bundle exec rake db:migrate --trace
>  - bundle exec rake db:test:prepare
>  - bundle exec rspec -f d spec/
>```
>
>Klikkaa sitten Travisin sivulta linkkiä "sign in with github" ja anna tunnuksesi.
>
>Mene oikeassa ylänurkassa olevan nimesi kohdalle ja valitse "accounts". Kytke avautumasta näkymästä ratebeer-repositoriosi jatkuva integraatio päälle.
>
>Kun seuraavan kerran pushaat koodia githubiin, suorittaa Travis automaattisesti buildausskriptin, joka siis määrittelee testit suoritettaviksi. Saat sähköpostitse tiedotuksen jos buildin status muuttuu.
>
>Lisää repositoriosi README-tiedostoon linkki sovelluksen TravisCI-sivulle:
>
>```ruby
>[![Build Status](https://travis-ci.org/mluukkai/ratebeer.png)](https://travis-ci.org/mluukkai/ratebeer)
>```
>
>Näin kaikki asianosaiset näkevät sovelluksen tilan ja todennäköisyys ettei sovelluksen testejä rikota kasvaa!

## Continuous delivery

Jatkuvaa integraatiota vielä askeleen eteenpäin viety käytäntö on jatkuva toimittaminen eng. continuous delivery http://en.wikipedia.org/wiki/Continuous_delivery jonka yhtenä osatekijänä on jatkuva deployaus, eli idea jonka mukaan koodi aina integroimisen yhteydessä myös deployataan tuotantoympäristön kaltaiseen ympäristöön tai parhaassa tapauksessa suoraan tuotantoon.

Eriyisesti Web-sovellusten yhteydessä jatkuva deployaaminen saattaa olla hyvinkin vaivaton operaatio.

> ## Tehtävä 13
>
> Toteuta sovelluksellesi jatkuva deployaaminen Herokuun Travis-CI:n avulla
>
> Ks. ohjeita seuraavista
http://about.travis-ci.org/docs/user/deployment/heroku/
ja http://about.travis-ci.org/blog/2013-07-09-introducing-continuous-deployment-to-heroku/


## Koodin laatumetriikat

Testauskattavuuden lisäksi myös koodin laatua kannattaa valvoa. SaaS-palveluna toimivan Codeclimaten https://codeclimate.com avulla voidaan generoida Rails-koodista erilaisia laatumetriikoita.

> ## Tehtävä 14
>
>Codeclimate on ilmainen opensource-projekteille. Rekisteröi projektisi sivulta https://codeclimate.com/pricing löytyvän linkin "Add an OS repo" avulla.
>
>Codeclimate valittelee hiukan koodissa olevasta samanlaisuudesta. Kyseessä on kuitenkin rails scaffoldingin
luoma hieman ruma koodi joten jätämme sen paikalleen.
>
>Linkitä myös laatumetriikkaraportti repositorion README-tiedostoon:
>
>```ruby
>[![Code Climate](https://codeclimate.com/github/mluukkai/ratebeer.png)](https://codeclimate.com/github/mluukkai/ratebeer)
>```
>
>Nyt myös codeclimate aiheuttaa sovelluskehittäjälle sopivasti painetta pitää koodi koko ajan hyvälaatuisena!

## Kirjautuneiden toiminnot

Jätetään testien teko hetkeksi ja palataan muutamaan aiempaan teemaan. Viikolla 2 rajoitimme http basic -autentikaation avulla sovellustamme siten, että ainoastaan admin-salasanan syöttämällä oli mahdollista lisätä ja poistaa panimoita. Sen sijaan oluiden ja reittausten teko on tällä hetkellä mahdollista jopa ilman kirjautumista.

Muutetaan sovellusta siten, että reittauksia voivat ja oluita sekä panimoita voivat luoda ja muokata ainoastaan kirjautuneet käyttäjät.

Sallitaan siis panimoiden luominen muillekin kuin ylläpitäjille, eli muokataan olutkontrollerin esifiltteriä siten, että se suoritetaan vaan metodin <code>destroy</code> suorituksen yhteydessä:

```ruby
class BreweriesController < ApplicationController
  before_filter :authenticate, :only => [:destroy]
  # ...
```

Näkymistä on helppo poistaa oluiden ja panimoiden muokkaus ja luontilinkit sekä linkki reittausten tekemiseen siinä tapauksessa, jos käyttäjä ei ole kirjautunut järjestelmään.

Esim. näkymästä views/beers/index.html.erb voidaan nyt poistaa kirjautumattomilta käyttäjiltä sivun lopussa oleva oluiden luomislinkki:

```erb
<% if not current_user.nil? %>
  <%= link_to('New Beer', new_beer_path) %>
<% end %>
```

Eli linkkielementti näytetään ainoastaan jos <code>current_user</code> ei ole <code>nil</code>. Voimme myös hyödyntää if:in kompaktimpaa muotoa:

```erb
<%= link_to('New Beer', new_beer_path) if not current_user.nil? %>
```

Nyt siis <code>link_to</code> metodi suoritetaan (eli linkin koodi renderöityy) ainoastaan jos if:in ehto on tosi. if not -muotoiset ehtolauseet eivät ole kovin hyvää rubyä, parempi olisikin käyttää <code>unless</code>-ehtolausetta:

```erb
<%= link_to('New Beer', new_beer_path) unless current_user.nil? %>
```

Eli renderöidään linkki __ellei__ <code>current_user</code> ei ole <code>nil</code>.

Oikeastaan <code>unless</code> on nyt tarpeeton, rubyssä nimittäin <code>nil</code> tulkitaan epätodeksi, eli kaikkien siistein muoto komennosta on

```erb
<%= link_to('New Beer', new_beer_path) if current_user %>
```

Poistamme lisäys-, poisto- ja editointilinkit pian, ensin kuitenkin tarkastellaan kontrolleritason suojausta, nimittäin vaikka kaikki linkit rajoitettuihin toimenpiteisiin poistettaisiin, ei mikään estä tekemästä suoraa HTTP-pyyntöä sovellukselle ja tekemästä näin kirjautumattomilta rajoitettua toimenpidettä.

On siis vielä tehtävä kontrolleritasolle varmistus, että jos kirjautumaton käyttäjä jostain syystä yrittää tehdä suoraan HTTP:llä kielletyn toimenpidettä, ei toimenpidettä suoriteta.

Päätetään ohjata rajoitettua toimenpidettä yrittävä kirjautumaton käyttäjä kirjautumissivulle.

Määritellään luokkaan <code>ApplicationController</code>  seuraava metodi:

```ruby
  def ensure_that_signed_in
    redirect_to signin_path, :notice => 'you should be signed in' if current_user.nil?
  end
```

Eli jos metodia kutsuttaessa käyttäjä ei ole kirjautunut, suoritetaan uudelleenohjaus kirjautumissivulle. Metodi on nyt kaikkien kontrollereiden käytössä.

Lisätään metodi esifiltteriksi (ks. http://guides.rubyonrails.org/action_controller_overview.html#filters ja https://github.com/mluukkai/WebPalvelinohjelmointi2013/wiki/viikko-2#yksinkertainen-suojaus) olut- ja panimo- ja muille metodeille paitsi index:ille ja show:lle:

```ruby
class BeersController < ApplicationController
  before_filter :ensure_that_signed_in, :except => [:index, :show]

  #...
end
```

Esim. uutta olutta luotaessa, ennen metodin <code>create</code> suoritusta, Rails suorittaa esifiltterin <code>ensure_that_signed_in</code>, joka ohjaa kirjautumattoman käyttäjän kirjautumissivulle. Jos käyttäjä on kirjautunut järjestelmään, ei filtterimetodi tee mitään, ja uusi olut luodaan normaaliin tapaan.

Kokeile selaimella, että muutokset toimivat, eli että kirjautumaton käyttäjä ohjautuu kirjautumissivulle kaikilla esifiltterillä rajoitetuilla toiminnoilla mutta että kirjautuneet pääsevät sivuille ilman ongelmaa.

> ## Tehtävä 15
>
> Rajoita esifiltterillä reittauksiin liittyen kirjautumattomalta käyttäjältä muut toiminnot paitsi kaikkien reittausten listaaminen.
>
> Rajoita User-kontrollerista kirjautumattomilta käyttäjiltä muut toiminnot paitsi kaikkien käyttäjien listaaminen sekä uuden käyttäjän luominen.
>
> Kun olet varmistanut että toiminnallisuus on kunnossa, voit halutessasi poistaa näkymistä panimoiden, oluiden, olutseurojen ja reittausten luomis-, poisto- ja editointilinkit kirjautumattomilta käyttäjiltä
>
> Jos joku sovellukseen aiemmin tehdyistä testeistä meni laajennuksen takia rikki, korjaa testit

> ## Tehtävä 16
>
> Tällä hetkellä panimoiden poistaminen on suojattu edelleen HTTP basic auth -mekanismilla. Päätämme kuitenkin luopua tästä sillä voimme aivan hyvin laajentaa järjestelmää siten, että osa operaatioista on rajoitettu vain pienelle osalle kirjautuneita käyttäjiä.
>
> * luo User-modelille uusi boolean-muotoinen kenttä <code>admin</code>, jonka avulla merkataan ne käyttäjät joilla on ylläpitäjän oikeudet järjestelmään
> * riittää, että käyttäjän voi tehdä ylläpitäjäksi ainoastaan konsolista
> * tee panimon poistamisesta ainoastaan ylläpitäjälle mahdollinen toimenpide

## Oman sovelluksen laajentaminen

**HUOM**: omaa sovellusta ei lasketa kurssin 4op laajuuden laskaripisteisiin ollenkaan. Jos oman sovelluksen tekee viikkoilla 1-4 määritellyssä laajuudessa, saa kurssista 5op. Tällöin oman sovelluksen deadline on 3. periodin alku. Omaa sovellusta on mahdollisuus laajentaa vielä tästäkin. Laajennusehdotus tulee itse speksata ja hyväksyttää. Tällöin kurssista saa 6op. Deadline tälle 6op:n laajuiselle versiolle sovitaan tapauskohtaisesti.

> ## Tehtävä 17
>
> Tee jollekin sovelluksesi epätriviaalille Modelille muutamia yksikkötestejä

> ## Tehtävä 18
>
> Tee jollekin sovelluksesi capybaraa käyttäviä selaintason testejä. Testaa ainakin tietokannassa olevan tiedon renderöitymistä, lomakkeen kautta tiedon lisäämistä sekä kirjautumista (jos sellainen toiminto sovelluksessasi on)

> ## Tehtävä 19
>
> Lisää sovelluksesi Travis-CI:hin ja codeclimateen. Lisää molempien palvelujen tarjoama statuslinkki sovelluksesi readmehen.

## Tehtävien palautus

Commitoi kaikki tekemäsi muutokset ja pushaa koodi githubiin. Deployaa uusin versio myös Herokuun. Lisää githubin readme-tiedostoon linkki sovelluksen heroku-instanssiin.

Kirjaa tehtävät palautetuksi osoitteeseen http://rorwadstats-2013.herokuapp.com/

Omaa sovellusta ei tässä vaiheessa tarvitse palauttaa!

Anna palautetta viikosta tekemällä issue osoitteessa https://github.com/mluukkai/WebPalvelinohjelmointi2013/issues/new

Koska kurssi on betatestausvaiheessa, on kaikenlainen palaute arvokasta, eli mikä toimi ja mikä ei, oliko viikko liian työläs, mistä asioista kaivattaisiin enemmän tukea materiaaliin, jne...
