/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

// AQUILA: Grid was removed upstream (BeeStation#14416), but our interfaces still lay out columns with it.

import { CSSProperties, PropsWithChildren } from 'react';
import { Table } from 'tgui-core/components';

type GridProps = PropsWithChildren<Record<string, any>>;

/** @deprecated Use Stack or Table instead */
export const Grid = (props: GridProps) => {
  const { children, ...rest } = props;
  return (
    <Table {...rest}>
      <Table.Row>{children}</Table.Row>
    </Table>
  );
};

type GridColumnProps = PropsWithChildren<{
  size?: number;
  style?: CSSProperties;
  [key: string]: any;
}>;

/** @deprecated Use Stack or Table instead */
export const GridColumn = (props: GridColumnProps) => {
  const { size = 1, style, ...rest } = props;
  return (
    <Table.Cell
      style={{
        width: size + '%',
        ...style,
      }}
      {...rest}
    />
  );
};

Grid.Column = GridColumn;
