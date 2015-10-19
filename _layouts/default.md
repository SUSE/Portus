<!DOCTYPE html>
<html>
  <head>
    <title>Portus: {{ page.title }}</title>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- bootstrap + Portus theme -->
    <link href="/assets/stylesheets/portus.css" type="text/css" rel="stylesheet" />
    <!--external libraries CSS -->
    <link href="/assets/stylesheets/animate/animate.css"              type="text/css" rel="stylesheet" />
    <link href="/assets/stylesheets/fontawesome/font-awesome.min.css" type="text/css" rel="stylesheet" />
    <!--external libraries JS -->
    <script src="/assets/js/jquery.min.js"      type="text/javascript"></script>
    <script src="/assets/js/bootstrap.min.js"   type="text/javascript"></script>
    <script src="/assets/js/wow.js"             type="text/javascript"></script>
    <script src="/assets/js/smoothscroll.js"    type="text/javascript"></script>
    <script src="/assets/js/jquery-cookie.js"   type="text/javascript" charset="utf-8"></script>
    <script src="/assets/js/jquery-lang.js"     type="text/javascript" charset="utf-8"></script>
    <!--portus js-->
    <script src="/assets/js/portus-language.js" type="text/javascript"></script>
    <script src="/assets/js/portus.js" type="text/javascript"></script>
    <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="//oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
      <script src="//oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>
  <body>
    <header>
      <div class="container-fluid">
        <img class="img-responsive" src="/assets/images/logo-header.png">
      </div>
    </header>

    {{ content }}

    <footer>
      <div class="row row-0">
        <div class="col-sm-2">
          <div class="dropup">
            <button class="btn btn-default dropdown-toggle" type="button" id="dropdownMenu1" data-toggle="dropdown" aria-haspopup="true" aria-expanded="true">
              <span class="selected-language">English</span>
              <span class="caret"></span>
            </button>
            <ul class="dropdown-menu" aria-labelledby="dropdownMenu1">
              <li><a href="#" class="change-language" data-language-value="en">English</a></li>
              <li><a href="#" class="change-language" data-language-value="es">Spanish</a></li>
            </ul>
          </div>
        </div>
        <div class="col-sm-8 text-center" lang="en">Created with <i class='fa fa-heart secondary-colour'></i> by the SUSE team</div>
      </div>
    </footer>
  </body>
</html>
