<cfimport taglib="/cfspec" prefix="">

<describe hint="BeCloseTo">

  <before>
    <cfset $matcher = $(createObject("component", "cfspec.lib.matchers.BeCloseTo").init(5, 0.5))>
  </before>

  <it should="match when actual == expected">
    <cfset $matcher.isMatch(5).shouldBeTrue()>
  </it>

  <it should="match when actual > (expected - delta)">
  	<cfset $matcher.isMatch(4.51).shouldBeTrue()>
  </it>

  <it should="match when actual < (expected + delta)">
  	<cfset $matcher.isMatch(5.49).shouldBeTrue()>
  </it>

  <it should="not match when actual == (expected - delta)">
  	<cfset $matcher.isMatch(4.5).shouldBeFalse()>
  </it>

  <it should="not match when actual < (expected - delta)">
  	<cfset $matcher.isMatch(4.49).shouldBeFalse()>
  </it>

  <it should="not match when actual == (expected + delta)">
  	<cfset $matcher.isMatch(5.5).shouldBeFalse()>
  </it>

  <it should="not match when actual > (expected + delta)">
  	<cfset $matcher.isMatch(5.51).shouldBeFalse()>
  </it>

  <it should="provide a useful failure message">
  	<cfset $matcher.isMatch(5.51)>
    <cfset $matcher.getFailureMessage().shouldEqual("expected 5 +/- (< 0.5), got 5.51")>
  </it>

  <it should="describe itself">
  	<cfset $matcher.getDescription().shouldEqual("be close to 5 (within +/- 0.5)")>
  </it>

</describe>