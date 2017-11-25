import React from 'react';
import { AuthRoute, ProtectedRoute } from '../../util/route_util';
import { Link, withRouter } from 'react-router-dom';
import { stringifyIntegerNoCommas } from '../../util/parsing_functions';

const StockIndexItem = ({ company }) => {
  return (
    <li className="stock-index-item">
      <div className="stock-text">
        <h4 className="stock-symbol">{company.symbol}</h4>
        <span className="stock-num-shares">{company.num_shares} Shares</span>
      </div>
      <img
        src="https://github.com/avelasco920/stocks-overflow/blob/master/app/assets/images/chart%20thumbnail/Screen%20Shot%202017-11-24%20at%203.30.55%20PM.png?raw=true"
        className="chart-thumb"/>
      <span className="stock-price">
        ${stringifyIntegerNoCommas(company.market_price)}
      </span>
    </li>
  );
};

export default StockIndexItem;