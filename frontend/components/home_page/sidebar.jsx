import React from 'react';
import { AuthRoute, ProtectedRoute } from '../../util/route_util';
import { Link, withRouter } from 'react-router-dom';

import StockIndexContainer from './stock_index_container';

class SideBar extends React.Component {
  render() {
    return (
      <div className="home-sidebar">
        <StockIndexContainer />
      </div>
    );
  }
}

export default SideBar;
