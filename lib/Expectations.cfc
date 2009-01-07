<cfcomponent output="false"><cfscript>

  $matchers = [
    "Equal(Numeric|Date|Boolean|String|Object|Struct|Array|Query)?(NoCase)?/Equal",
    "BeCloseTo/BeCloseTo",
    "Be(GreaterThanOrEqualTo|GreaterThan|LessThanOrEqualTo|LessThan)/BeComparison",
    "Have(AtLeast|AtMost|Exactly)?/Have",
    "Match(NoCase)?/Match",
    "Contain/Contain",
    "Be(.+)/Be",
    "Throw/Throw"
  ];

  function init(runner, target) {
    $runner = runner;
    $target = target;
    return this;
  }

  function getExpectedException() {
    return $runner.getExpectedException();
  }

  function setExpectedException(e) {
    return $runner.setExpectedException(e);
  }

  function resumeDelayedMatcher(matcher, negate) {
    var result = matcher.isMatch($target);

    if (result eqv negate) {
      if (negate) {
        return $runner.fail(matcher.getNegativeFailureMessage());
      } else {
        return $runner.fail(matcher.getFailureMessage());
      }
    }
    return true;
  }

  function onMissingMethod(missingMethodName, missingMethodArguments) {
    var regexp = "";
    var matchData = "";
    var matcher = "";
    var args = "";
    var flatArgs = "";
    var result = "";
    var i = "";
    var j = "";
    var k = "";

    result = $runner.getExpectedException();
    if (!isSimpleValue(result)) {
      if (listFindNoCase("shouldThrow,shouldNotThrow", missingMethodName)) {
        $runner.setExpectedException(result);
      } else {
        createObject("component", "cfspec.lib.Matcher").rethrow(result);
      }
    }

    for (i = 1; i <= arrayLen($matchers); i++) {
      regexp = $matchers[i];
      matchData = reFindNoCase("^should(Not)?#listFirst(regexp, '/')#$", missingMethodName, 1, true);
      if (matchData.len[1]) {
        k = 1;
        args = [];
        for (j = 3; j <= arrayLen(matchData.len); j++) {
          if (matchData.len[j]) arrayAppend(args, mid(missingMethodName, matchData.pos[j], matchData.len[j]));
          else arrayAppend(args, "");
          flatArgs = listAppend(flatArgs, "args[#k#]");
          k++;
        }
        for (j = 1; j <= arrayLen(missingMethodArguments); j++) {
          arrayAppend(args, missingMethodArguments[j]);
          flatArgs = listAppend(flatArgs, "args[#k#]");
          k++;
        }

        matcher = createObject("component", "cfspec.lib.matchers.#listLast(regexp, '/')#");
        evaluate("matcher.init(#flatArgs#)");

        negate = matchData.len[2];
        matcher.setExpectations(this, negate);
        if (matcher.isDelayed()) return matcher;
        result = matcher.isMatch($target);

        if (result eqv negate) {
          if (negate) {
            return $runner.fail(matcher.getNegativeFailureMessage());
          } else {
            return $runner.fail(matcher.getFailureMessage());
          }
        }
        return this;
      }
    }

    if (isObject($target)) {
      args = [];
      for (i = 1; i <= arrayLen(missingMethodArguments); i++) {
        arrayAppend(args, missingMethodArguments[i]);
        flatArgs = listAppend(flatArgs, "args[#i#]");
      }
      try {
        result = evaluate("$target.#missingMethodName#(#flatArgs#)");
      } catch (Any e) {
        $runner.setExpectedException(e);
        return $runner.$(this);
      }
      if (!isDefined("result")) result = false;
      return $runner.$(result);
    } else {
      createObject("component", "cfspec.lib.Matcher").throw("Application", "The method #missingMethodName# was not found.");
    }
  }

</cfscript></cfcomponent>