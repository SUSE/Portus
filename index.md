---
title: Portus
layout: default
---

<div id="frontmatter" class="row">
    <div class="center-block">
        <h2 class="text-uppercase" lang="en">Claim control of your Docker images</h2>
        <hr>
        <a href="https://github.com/SUSE/Portus#containerized" class="btn btn-primary" lang="en">Try out Portus</a>
        <a href="https://github.com/SUSE/Portus" class="btn btn-primary" lang="en">View on GitHub</a>
        <a href="https://groups.google.com/forum/#!forum/portus-dev" class="btn btn-primary" data-wow-delay="700ms" lang="en">Mailing list</a>
    </div>
</div>

<div class="row main-section equal">
    <div class="col-md-8">
        <h3 class="text-justify">
            <a href="https://github.com/SUSE/Portus">Portus</a>
            is an open source authorization service and user interface for the next generation Docker Registry.
        </h3>
        <p>
            It is an <b>on-premise</b> application that allows users to
            administrate and secure their Docker registries.
        </p>
    </div>
    <div class="col-md-4 hidden-xs hidden-sm vcenter">
        <div class="center half"><img src="/images/portus-logo.png" alt="Portus logo" /></div>
    </div>
</div>

<div class="row main-section">
    <div class="col-md-5 vcenter hidden-xs hidden-sm">
        <img src="/images/members.png" alt="Team members" />
    </div>
    <div class="col-md-7">
        <h3>
            Secure
        </h3>
        <p>
            Portus implements the new authorization scheme defined by the latest
            version of the Docker registry. It allows for fine grained control
            over all of your images. You decide which users and teams are
            allowed to push or pull images.
        </p>
    </div>
    <div class="col-md-5 vcenter hidden-md hidden-lg">
        <img src="/images/members.png" alt="Team members" />
    </div>
</div>

<div class="row main-section equal">
    <div class="col-md-8">
        <h3>
            Easily manage users with teams
        </h3>
        <p>
            Map your company organization inside of Portus, define as many teams
            as you want and add and remove users from them.
        </p>
        <p>Teams have three different types of users to allow full granularity:</p>
        <ul>
            <li><b>Viewers</b>: can only pull images.</li>
            <li><b>Contributors</b>: can push and pull images.</li>
            <li><b>Owners</b>: like contrinutors, but can also add and remove users from the team</li>
        </ul>
        <a href="/features/2_LDAP-support.html">LDAP</a> is also supported!
    </div>
    <div class="col-md-4 hidden-xs hidden-sm">
        <div class="row users-row">
            <div title="Viewer" class="portus-users col-md-2 col-md-offset-3">
                <i class="fa fa-eye fa-2x"></i>
            </div>
        </div>
        <div class="row users-row">
            <div title="Contributor" class="portus-users col-md-2 col-md-offset-3">
                <i class="fa fa-exchange fa-2x"></i>
            </div>
        </div>
        <div class="row users-row">
            <div title="Owner" class="portus-users col-md-2 col-md-offset-3">
                <i class="fa fa-male fa-2x"></i>
            </div>
        </div>
    </div>
</div>

<div class="row main-section">
    <div class="col-md-4 vcenter hidden-xs hidden-sm">
        <img src="/images/search.jpg" alt="Search widget" />
    </div>
    <div class="col-md-8">
        <h3>
            Search
        </h3>
        <p>
Portus provides an intuitive overview of the contents of your private
registry. It also features a search capability to find images even faster.
</p>
<p>
User privileges are constantly taken into account, even when browsing the
contents of the repository or when performing searches.
        </p>
    </div>
    <div class="col-md-4 vcenter hidden-md hidden-lg">
        <img src="/images/search.jpg" alt="Search widget" />
    </div>
</div>

<div class="row main-section">
    <div class="col-md-7">
        <h3>
            Audit
        </h3>
        <p>
Keep everything under control. All the relevant events are automatically logged
by Portus and are available for analysis by admin users.
</p>
<p>
Non-admin users can also use this feature to keep up with relevant changes.
</p>
    </div>
    <div class="col-md-5 vcenter">
        <img src="/images/audit.png" alt="Auditing" />
    </div>
</div>

<div class="row main-section">
    <div class="center-block">
        <h3 class="text-uppercase" lang="en">And more...</h3>
        <hr>
        <p>The <a href="/features.html">features</a> page contains the full list, but to highlight some of them:</p>
        <ul>
            <li><a href="/features/6_security_scanning.html">Security scanning</a>.</li>
            <li><a href="/features/oauth.html">OAuth and OpenID authentication</a>.</li>
            <li><a href="/features/7_disabling_users.html">Disabling</a> or <a href="/features/8_locking.html">locking</a> users.</li>
            <li><a href="/features/application_tokens.html">Application tokens</a>.</li>
        </ul>
    </div>
</div>
