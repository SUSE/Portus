---
title: Portus by SUSE
layout: default
---

  <section id="welcome" class="text-center">
    <div class="container-fluid">
      <h2 class="text-uppercase wow fadeInUp" lang="en">Claim control of your</h2>
      <h1 class="text-uppercase wow fadeInUp" lang="en">Docker images</h1>
      <hr class="wow zoomIn img-responsive" data-wow-delay="500ms">
      <a href="https://github.com/SUSE/Portus" class="btn btn-primary wow fadeInUp" data-wow-delay="700ms" lang="en">View on GitHub</a>
      <a href="#" data-linkto="try-portus" class="smoothScroll btn btn-primary wow fadeInUp" data-wow-delay="900ms" lang="en">Try out Portus</a>
    </div>
  </section>
  <section id="what-is-portus" class="text-center fixit-container">
    <div class="container-fluid">
      <h2 class="wow fadeInUp" lang="en">What is Portus</h2>
      <p class="wow fadeInUp" lang="en">Portus is an open source authorization service and user interface for the next generation Docker Registry.</p>
      <img class="img-responsive docker-logo fixit-element" src="assets/images/docker-logo.png" />
      <img class="img-responsive portus-computer wow fadeIn" src="assets/images/portus-computer.jpg" />
    </div>
  </section>
  <section id="why-use-portus" class="text-center">
    <div class="container-fluid">
      <h2 class="wow fadeInUp text-uppercase" lang="en">Why use Portus</h2>
      <p class="wow fadeInUp" lang="en">The Docker Hub is a wonderful place, but what if you cannot, or do not wish to push your images to a third party registry? You may setup a private instance of the Docker registry, but then everyone in your organization has push and pull privileges over all of your images.
      </p>
      <p class="wow fadeInUp" lang="en">How do you keep track of all of the images in your private registry?</p>
      <h4 class="wow lightSpeedIn" lang="en">Portus to the rescue!</h4>
      <i class="fa fa-life-ring fa-5x wow bounceIn"></i>
    </div>
  </section>
  <section id="secure">
    <div class="container-fluid">
      <div class="row">
        <div class="col-sm-6 wow fadeInLeft">
          <h2 class="wow fadeInUp" lang="en">Secure</h2>
          <p class="wow fadeInUp" lang="en">Portus implements the new authorization scheme defined by the latest version of the Docker registry. It allows for fine grained control over all of your images. You decide which users and teams are allowed to push or pull images.</p>
        </div>
        <div class="col-sm-6 text-center wow fadeInRight">
          <img class="img-responsive" src="assets/images/secure.png" />
        </div>
      </div>
    </div>
  </section>
  <section id="manage-users" class="text-center">
    <div class="container-fluid">
      <h2 class="wow fadeInUp" lang="en">Easily manage users with teams</h2>
      <p class="wow fadeInUp" lang="en">Map your company organization inside of Portus, define as many teams as you want and add and remove users from them.</p>
      <p class="wow fadeInUp" lang="en">Teams have three different types of users to allow full granularity:</p>
      <div class="row users-container">
        <div class="col-sm-4 wow bounceIn" data-wow-delay="200ms">
          <div class="portus-users">
            <i class="fa fa-eye fa-5x"></i>
          </div>
          <h3 lang="en">Viewers</h3>
          <p lang="en">Can only pull images.</p>
        </div>
        <div class="col-sm-4 wow bounceIn" data-wow-delay="500ms">
          <div class="portus-users">
            <i class="fa fa-users fa-5x"></i>
          </div>
          <h3 lang="en">Contributors</h3>
          <p lang="en">Can push and pull images.</p>
        </div>
        <div class="col-sm-4 wow bounceIn" data-wow-delay="800ms">
          <div class="portus-users">
            <i class="fa fa-male fa-5x"></i>
          </div>
          <h3 lang="en">Owners</h3>
          <p lang="en">Like contributors, but can also add and remove users from the team.</p>
        </div>
      </div>
    </div>
  </section>
  <section id="search">
    <div class="container-fluid">
      <div class="row">
        <div class="col-sm-6 wow fadeInLeft">
          <h2 class="wow fadeInUp" lang="en">Search</h2>
          <p class="wow fadeInUp" lang="en">Portus provides an intuitive overview of the contents of your private registry. It also features a search capability to find images even faster.</p>
          <p class="wow fadeInUp" lang="en">User privileges are constantly taken into account, even when browsing the contents of the repository or when performing searches.</p>
        </div>
        <div class="col-sm-6 text-center wow fadeInRight">
          <img class="img-responsive" src="assets/images/search.jpg" />
        </div>
      </div>
    </div>
  </section>
  <section id="audit">
    <div class="container-fluid">
      <div class="row">
        <div class="col-sm-6 text-center wow fadeInLeft">
          <img class="img-responsive" src="assets/images/audit.jpg" />
        </div>
        <div class="col-sm-6 wow fadeInRight text-right">
          <h2 class="wow fadeInUp" lang="en">Audit</h2>
          <p class="wow fadeInUp" lang="en">Keep everything under control. All the relevant events are automatically logged by Portus and are available for analysis by admin users.</p>
          <p class="wow fadeInUp" lang="en">Non-admin users can also use this feature to keep up with relevant changes.</p>
        </div>
      </div>
    </div>
  </section>
  <section id="try-portus" class="text-center">
    <div class="container-fluid">
      <h2 class="wow fadeInUp" lang="en">Try Portus</h2>
      <div class="row snippet">
        <div class="col-sm-6 text-left">
          <p class="wow fadeInUp"><span lang="en">Try Portus with </span> <a href='http://docs.docker.com/compose/'>docker-compose</a>:</p>
          <pre>
$ git clone https://github.com/SUSE/Portus.git
$ cd Portus
$ ./compose-setup.sh
          </pre>
        </div>
        <div class="col-sm-6 text-left">
          <p class="wow fadeInUp"><span lang="en">We provide also a ready to go</span> <a href='https://github.com/SUSE/Portus/wiki/Installing-Portus#the-appliance' lang="en"> appliance</a> <span lang="en">based on openSUSE.</span></p>
          <p class="wow fadeInUp" lang="en">All Portus documentation, including the installation guide is available in our</span> <a href='https://github.com/SUSE/Portus/wiki'> wiki</a>.</p>
          <p class="wow fadeInUp"><span lang="en">We provide also a set of example setups. Make sure to check them out:</span></p>
          <ul>
            {% for post in site.posts %}
            <li><a href="{{ post.url }}">{{ post.title }}</a>: {{ post.description }}</li>
            {% endfor %}
          </ul>
        </div>
      </div>


    </div>
  </section>
  <section id="feedback" class="text-center">
    <div class="container-flui">
      <h3 class="wow fadeInUp" lang="en">Feedback, comments, contributions?</h3>
      <p class="wow fadeInUp"><span lang="en">Open an</span> <a href='https://github.com/SUSE/Portus/issues' lang="en"> issue</a> <span lang="en">or subscribe to the</span> <a href='http://lists.suse.com/mailman/listinfo/containers'>containers@lists.suse.com</a> <span lang="en">mailing list.</span></p>
    </div>
  </section>
